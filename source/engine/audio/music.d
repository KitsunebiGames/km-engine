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
import events;

/**
    The game's main playlist instance
*/
__gshared Playlist GamePlaylist;

/**
    Initializes the game's main playlist instance
*/
void initPlaylist() {
    GamePlaylist = new Playlist();
    GamePlaylist.addMusicFrom("assets/music/");
}

/**
    A playlist of music
*/
class Playlist {
private:
    bool isStopped = true;
    size_t current;
    Music[] songs;

    // Smarter shuffle function that avoids playing the same track twice
    size_t smartShuffle() {
        import std.random : uniform;
        size_t value;
        do {
            value = uniform(0, songs.length);
        } while(value != current);
        return value;
    }

    void nextSong() {

        // If we skip to the next song stop the current one from playing
        if (songs[current].isPlaying) {
            songs[current].stop();
        }

        // Next song is the same
        if (repeatOne) {
            songs[current].play();
            return;
        }

        if (shuffle) {

            // Shuffle to next song using the "smart" algorithm
            current = smartShuffle();
        } else {
            // Increment song id
            current++;

            // Constrain ids to the length of the song array
            current %= songs.length;
        }

        // Play the new song
        songs[current].play();
        onSongChange(cast(void*)this, songs[current].getInfo());
    }

public:

    ~this() {
        foreach(song; songs) {
            destroy(song);
        }
    }

    /**
        Repeat a single song
    */
    bool repeatOne;

    /**
        Shuffle songs
    */
    bool shuffle;

    /**
        Event called when song changes
    */
    Event!AudioInfo onSongChange = new Event!AudioInfo();

    /**
        Add Music to the playlist
    */
    void addMusic(Music music) {
        songs ~= music;

        // We want to roll over to the first song so set it to the last
        current = songs.length-1;
    }

    /**
        Adds all .ogg files that could be found in a path recursively
    */
    void addMusicFrom(string path) {
        import std.file : dirEntries, SpanMode;
        import std.algorithm : filter, endsWith;
        foreach(entry; dirEntries(path, SpanMode.depth).filter!(f => f.name.endsWith(".ogg"))) {
            addMusic(new Music(entry));
            AppLog.info("Playlist", "Added song %s...", entry);
        }
    }

    /**
        Play the playlist
    */
    void play() {
        isStopped = false;
        nextSong();
    }

    /**
        Stop music from playing
    */
    void stop() {
        isStopped = true;
        songs[current].stop();
    }

    /**
        Gets whether the current song is playing
    */
    bool isCurrentSongPlaying() {
        return songs[current].isPlaying();
    }

    /**
        Play next song
    */
    void next() {

        // Avoid accidentally starting the playlist again
        if (isStopped) return;

        // Play the next song in the playlist
        nextSong();
    }

    /**
        Updates the playlist
    */
    void update() {

        // Skip if we're stopped
        if (isStopped) return;

        // Play next song if the current one is stopped
        if (!isCurrentSongPlaying) next();
    }
}

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
        if (playerThread !is null) playerThread.join();
    }

    /**
        Gets whether a song is currently playing
    */
    bool isPlaying() {
        return running;
    }

    /**
        Get info about the music
    */
    AudioInfo getInfo() {
        return stream.getInfo();
    }
}