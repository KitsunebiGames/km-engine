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
import std.range;

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
    Information about audio, usually music
*/
struct AudioInfo {

    /**
        The file of the audio
    */
    string file;

    /**
        The title of the audio
    */
    string title;

    /**
        The artist behind the music
    */
    string artist;

    /**
        The person performing the music
    */
    string performer;

    /**
        The person performing the music
    */
    string album;

    /**
        Date of release, usually year
    */
    string date;

    /**
        Get the audio info as a string
    
        According to Danish law even things CC0 or public domain has to include crediting
        In the case the music doesn't (eg. the player drags music in to the game's music folder that is pirated)
        We'll leave a little message for them :)
    */
    string toString() {
        if (artist.empty || title.empty) return "%s\n[Info missing! yarr harr?]".format(file);

        string base = "%s - %s".format(artist, title);
        if (!album.empty) base ~= " from %s".format(album);
        if (!date.empty) base ~= " (%s)".format(date);
        if (!performer.empty) base ~= "\nPerfomed by %s".format(performer);
        return base;
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

    /**
        Try to get the information about the audio

        This information is usually only used for music
    */
    AudioInfo getInfo();
}