/*
    Copyright © 2020, Luna Nielsen
    Distributed under the 2-Clause BSD License, see LICENSE file.
    
    Authors: Luna Nielsen
*/
module engine.audio.sound;
import engine.audio.astream;
import bindbc.openal;
import engine.math;

/**
    A sound
*/
class Sound {
private:
    ALuint bufferId;
    ALuint sourceId;

public:
    ~this() {
        alDeleteSources(1, &sourceId);
        alDeleteBuffers(1, &bufferId);
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
        alGenBuffers(1, &bufferId);
        ubyte[] data = stream.readAll();
        alBufferData(bufferId, stream.format, data.ptr, cast(int)data.length, cast(int)stream.bitrate/stream.channels);

        // Generate source
        alGenSources(1, &sourceId);
        alSourcei(sourceId, AL_BUFFER, bufferId);
        alSourcef(sourceId, AL_PITCH, 1);
        alSourcef(sourceId, AL_GAIN, 0.5);
    }

    /**
        Play sound
    */
    void play(float gain = 0.5, float pitch = 1, vec3 position = vec3(0)) {
        alSource3f(sourceId, AL_POSITION, position.x, position.y, position.z);
        alSourcef(sourceId, AL_PITCH, pitch);
        alSourcef(sourceId, AL_GAIN, gain);
        alSourcePlay(sourceId);
    }

    void setPitch(float pitch) {
        alSourcef(sourceId, AL_PITCH, pitch);
    }

    void setGain(float gain) {
        alSourcef(sourceId, AL_GAIN, gain);
    }

    /**
        Stop sound
    */
    void stop() {
        alSourceStop(sourceId);
    }
}