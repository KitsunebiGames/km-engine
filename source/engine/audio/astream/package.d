/*
    Copyright © 2020, Luna Nielsen
    Distributed under the 2-Clause BSD License, see LICENSE file.
    
    Authors: Luna Nielsen
*/
module engine.audio.astream;
import engine.audio.astream.ogg;
import std.path;
import bindbc.openal;
import std.format;

/**
    Open an audio file
*/
AudioStream open(string file, bool bit16 = true) {
    switch(file.extension) {
        case ".ogg": return new OggStream(file, bit16);
        default: throw new Exception("Unsupported file type (%s)".format(file.extension));
    }
}

/**
    Audio format of a stream
*/
enum Format {
    Mono8 = AL_FORMAT_MONO8,
    Mono16 = AL_FORMAT_MONO16,
    Stereo8 = AL_FORMAT_STEREO8,
    Stereo16 = AL_FORMAT_STEREO16
}

/**
    A stream of audio
*/
abstract class AudioStream {
public:
    /**
        The amount of channels in the audio stream
    */
    int channels;

    /**
        Audio format of the stream
    */
    Format format;

    /**
        Read all samples from the stream till the end
    */
    final ubyte[] readAll() {
        ubyte[] data = new ubyte[4096];
        ubyte[] outData;
        ptrdiff_t readCount = 0;
        do {
            readCount = readSamples(data);
            outData ~= data[0..readCount];
        } while(readCount > 0);
        
        if (canSeek) seek(0);
        return outData;
    }

abstract:
    /**
        Read samples from the audio stream in to the array

        Returns the amount of samples read
        Returns 0 if there's no more samples
    */
    ptrdiff_t readSamples(ref ubyte[] toArray);
    
    /**
        Gets whether the file can be seeked
    */
    bool canSeek();

    /**
        Seek to a PCM location in the stream
    */
    void seek(size_t location);

    /**
        Get the position in the stream
    */
    size_t tell();

    /**
        Gets the bitrate of the stream
    */
    size_t bitrate();
}