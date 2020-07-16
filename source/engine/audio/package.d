/*
    Copyright © 2020, Luna Nielsen
    Distributed under the 2-Clause BSD License, see LICENSE file.
    
    Authors: Luna Nielsen
*/
module engine.audio;
public import engine.audio.astream;
public import engine.audio.music;
public import engine.audio.sound;
import bindbc.openal;
import engine.math;

/**
    Initializes the audio engine
*/
void initAudioEngine() {
    // Open audio device and set context
    ALCdevice* dev = alcOpenDevice(null);
    auto ctx = alcCreateContext(dev, null);
    alcMakeContextCurrent(ctx);
}

/**
    Set the position of the listener
*/
void setListenerPosition(vec3 position) {
    alListener3f(AL_POSITION, position.x, position.y, position.z);
}