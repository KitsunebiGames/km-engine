/*
    Copyright © 2020, Luna Nielsen
    Distributed under the 2-Clause BSD License, see LICENSE file.
    
    Authors: Luna Nielsen
*/
module engine.audio.music;
import core.thread;
import engine.audio.astream;
import bindbc.openal;
import engine.math;
import std.math : isFinite;
import engine;

/**
    A stream of audio that can be played
*/
class Music {
private:
    enum MUSIC_BUFF_SIZE = 4096;
    enum MUSIC_BUFF_COUNT = 4;

    long lastReadLength;
    AudioStream stream;
    ALuint sourceId;
    ALint processed;

    bool running;
    bool looping;

    Thread playerThread;
    void playThread() {

        // The processing buffer
        ALuint pBuf;
        ubyte[] pBufData = new ubyte[MUSIC_BUFF_SIZE*MUSIC_BUFF_COUNT];
        ALint state;
        
        // The buffer chain
        ALuint[MUSIC_BUFF_COUNT] buffers;
        alGenBuffers(MUSIC_BUFF_COUNT, buffers.ptr);

        // Fill buffers with initial data
        foreach(i; 0..MUSIC_BUFF_COUNT) {
            lastReadLength = stream.readSamples(pBufData);
            alBufferData(buffers[i], stream.format, pBufData.ptr, cast(int)lastReadLength, cast(int)stream.bitrate);
            alSourceQueueBuffers(sourceId, 1, &buffers[i]);
        }

        // Start playing
        alSourcePlay(sourceId);
        mainLoop: while(running) {

            // Check how much data OpenAL has processed
            alGetSourcei(sourceId, AL_BUFFERS_PROCESSED, &processed);
            alGetError();

            while(processed--) {

                // Unqueue the most recent cleared buffer
                alSourceUnqueueBuffers(sourceId, 1, &pBuf);

                // Read samples to buffer
                lastReadLength = stream.readSamples(pBufData);

                if (lastReadLength == 0) {
                    // If we're at the end and we should loop then loop. (if possible)
                    if (looping && stream.canSeek) {

                        // Seek back to start of stream and read samples
                        stream.seek(0);
                        lastReadLength = stream.readSamples(pBufData);

                        debug AppLog.info("Music Debug", "Music %s looped...", sourceId);

                    } else {
                        break mainLoop;
                    }
                }

                // Buffer the data to OpenAL
                alBufferData(pBuf, stream.format, pBufData.ptr, cast(int)lastReadLength, cast(int)stream.bitrate);

                // Re-queue buffer
                alSourceQueueBuffers(sourceId, 1, &pBuf);

                // Get the current state of the buffer
                alGetSourcei(sourceId, AL_SOURCE_STATE, &state);

                // If stream is paused keep pausing here
                while (state == AL_PAUSED) {

                    // Quit out if the music is stopped
                    if (!running) break mainLoop;

                    // Otherwise wait
                    alGetSourcei(sourceId, AL_SOURCE_STATE, &state);
                    Thread.sleep(10.msecs);
                }

                // Make sure if the buffer stops (due to running out) that we restart it
                if (state != AL_PLAYING) {
                    alSourcePlay(sourceId);
                }
            }
            

            // Don't make the thread use all of the cpu
            Thread.sleep(10.msecs);
        }

        // Cleanup
        stream.seek(0);
        running = false;
        alDeleteBuffers(2, buffers.ptr);

        debug AppLog.info("Music Debug", "Music %s stopped...", sourceId);
    }

public:
    ~this() {
        this.stop();
        alDeleteSources(1, &sourceId);
    }

    /**
        Construct a sound from a file path
    */
    this(string file) {
        this(open(file));
    }

    /**
        Construct a sound
    */
    this(AudioStream stream) {

        // Generate buffer
        this.stream = stream;

        // Generate source
        alGenSources(1, &sourceId);
        alSourcef(sourceId, AL_PITCH, 1);
        alSourcef(sourceId, AL_GAIN, 0.5);
    }

    /**
        Play sound
    */
    void play(float gain = float.nan, float pitch = float.nan) {
        
        // We don't want to start multiple threads playing the same music
        if (running) return;

        // Seek back to start of music (just in case)
        if (lastReadLength == 0) {
            stream.seek(0);
        }

        // Set music start values if needed
        if (pitch.isFinite) alSourcef(sourceId, AL_PITCH, pitch);
        if (gain.isFinite) alSourcef(sourceId, AL_GAIN, gain);

        // Start thread and play music
        running = true;
        playerThread = new Thread(&playThread);
        playerThread.start();
    }

    /**
        Set the pitch of this music
    */
    void setPitch(float pitch) {
        alSourcef(sourceId, AL_PITCH, pitch);
    }

    /**
        Set the pitch of this music
    */
    void setGain(float gain) {
        alSourcef(sourceId, AL_GAIN, gain);
    }

    /**
        Set the pitch of this music
    */
    void setLooping(bool loop) {
        looping = loop;
    }

    /**
        Pause the song
    */
    void pause() {
        alSourcePause(sourceId);
    }

    /**
        Stop sound
    */
    void stop() {
        running = false;
        alSourceStop(sourceId);
        playerThread.join();
    }
}