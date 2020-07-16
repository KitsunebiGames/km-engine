/*
    Copyright © 2020, Luna Nielsen
    Distributed under the 2-Clause BSD License, see LICENSE file.
    
    Authors: Luna Nielsen
*/
module engine.audio.astream.ogg;
import engine.audio.astream;
import vorbisfile;
import std.string;
import engine.core.log;
import std.exception;

/**
    An Ogg Vorbis audio stream
*/
class OggStream : AudioStream {
private:
    OggVorbis_File file;
    int section;
    int word;
    int signed;


    void verifyError(int error) {
        switch(error) {
            case OV_EREAD: throw new Exception("A read from media returned an error");
            case OV_ENOTVORBIS: throw new Exception("File is not a valid ogg vorbis file");
            case OV_EVERSION: throw new Exception("Vorbis version mismatch");
            case OV_EBADHEADER: throw new Exception("Bad OGG Vorbis header");
            case OV_EFAULT: throw new Exception("OGG Vorbis bug or stack corruption");
            default: break;
        }
    }

public:

    /**
        Deallocates on deconstruction
    */
    ~this() {
        ov_clear(&file);
    }

    /**
        Opens the OGG Vorbis stream file
    */
    this(string file, bool bit16) {

        // Open the file and verify it opened correctly
        int error = ov_fopen(file.toStringz, &this.file);
        this.verifyError(error);

        // Get info about file
        auto info = ov_info(&this.file, -1);
        enforce(info.channels <= 2, "Too many channels in OGG Vorbis file");

        // Set info about this file
        this.channels = info.channels;
        if (this.channels == 1) {
            this.format = bit16 ? Format.Mono16 : Format.Mono8;
        } else {
            this.format = bit16 ? Format.Stereo16 : Format.Stereo8;
        }
        word = format == Format.Stereo8 || format == Format.Mono8 ? 1 : 2;
        signed = format == Format.Mono16 || format == Format.Stereo16 ? 1 : 0;
    }

override:
    ptrdiff_t readSamples(ref ubyte[] toArray) {

        // Read a verify the success of the read
        ptrdiff_t readAmount = cast(ptrdiff_t)ov_read(&file, cast(byte*)toArray.ptr, cast(int)toArray.length, 0, word, signed, &section);
        assert(readAmount >= 0, "An error occured trying to read from the ogg vorbis stream");
        return readAmount;
    }

    /**
        Gets whether the file can be seeked
    */
    bool canSeek() {
        return cast(bool)ov_seekable(&file);
    }

    /**
        Seek to a PCM location in the stream
    */
    void seek(size_t location) {
        ov_pcm_seek(&file, location);
    }

    /**
        Get the position in the stream
    */
    size_t tell() {
        return ov_pcm_tell(&file);
    }

    /**
        Gets the bitrate
    */
    size_t bitrate() {
        return ov_bitrate(&file, -1);
    }
}