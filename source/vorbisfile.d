/*
    Copyright © 2020, Luna Nielsen
    Distributed under the 2-Clause BSD License, see LICENSE file.
    
    Authors: Luna Nielsen
*/
module vorbisfile;
import core.stdc.config;

alias ogg_int64_t = long;
alias ogg_uint64_t = ulong;
alias ogg_int32_t = int;
alias ogg_uint32_t = uint;
alias ogg_int16_t = short;
alias ogg_uint16_t = ushort;

struct vorbis_info {
    int _version; // Renamed from "version", since that's a keyword in D
    int channels;
    int rate;
    c_long bitrate_upper;
    c_long bitrate_nominal;
    c_long bitrate_lower;
    c_long bitrate_window;

    void *codec_setup;
}

struct vorbis_dsp_state {
    int analysisp;
    vorbis_info* vi;
    float** pcm;
    float** pcmret;
    int pcm_storage;
    int pcm_current;
    int pcm_returned;
    int preextrapolate;
    int eofflag;
    c_long lW;
    c_long W;
    c_long nW;
    c_long centerW;
    ogg_int64_t granulepos;
    ogg_int64_t sequence;
    ogg_int64_t glue_bits;
    ogg_int64_t time_bits;
    ogg_int64_t floor_bits;
    ogg_int64_t res_bits;
    void* backend_state;
}

struct vorbis_comment {
    char** user_comments;
    int* comment_lengths;
    int comments;
    char* vendor;
}

struct alloc_chain {
    void* ptr;
    alloc_chain* next;
}

struct vorbis_block {
    float** pcm;
    oggpack_buffer opb;
    c_long lW;
    c_long W;
    c_long nW;
    int pcmend;
    int mode;
    int eofflag;
    ogg_int64_t granulepos;
    ogg_int64_t sequence;
    vorbis_dsp_state* vd;
    void* localstore;
    c_long localtop;
    c_long localalloc;
    c_long totaluse;
    alloc_chain* reap;
    c_long glue_bits;
    c_long time_bits;
    c_long floor_bits;
    c_long res_bits;
    void* internal;
}


struct ogg_iovec_t {
    void* iov_base;
    size_t iov_len;
}

struct oggpack_buffer {
    c_long endbyte;
    int endbit;
    ubyte* buffer;
    ubyte* ptr;
    c_long storage;
}

struct ogg_page {
    ubyte* header;
    c_long header_len;
    ubyte* _body;       // originally named "body", but that's a keyword in D.
    c_long body_len;
}

struct ogg_stream_state {
    ubyte* body_data;
    c_long body_storage;
    c_long body_fill;
    c_long body_returned;
    int* lacing_vals;
    ogg_int64_t* granule_vals;
    c_long lacing_storage;
    c_long lacing_fill;
    c_long lacing_packet;
    c_long lacing_returned;
    ubyte[282] header;
    int header_fill;
    int e_o_s;
    int b_o_s;
    c_long serialno;
    c_long pageno;
    ogg_int64_t packetno;
    ogg_int64_t granulepos;
}

struct ogg_packet {
    ubyte* packet;
    c_long bytes;
    c_long b_o_s;
    c_long e_o_s;
    ogg_int64_t granulepos;
    ogg_int64_t packetno;
}

struct ogg_sync_state {
    ubyte* data;
    int storage;
    int fill;
    int returned;

    int unsynced;
    int headerbytes;
    int bodybytes;
}

struct ov_callbacks {
    extern(C) nothrow {
        size_t function(void*, size_t, size_t, void*) read_func;
        int function(void*, ogg_int64_t, int) seek_func;
        int function(void*) close_func;
        c_long function(void*) tell_func;
    }
}

enum {
    NOTOPEN =0,
    PARTOPEN =1,
    OPENED =2,
    STREAMSET =3,
    INITSET =4,
    
    OV_FALSE      = -1,
    OV_EOF        = -2,
    OV_HOLE       = -3,
    OV_EREAD      = -128,
    OV_EFAULT     = -129,
    OV_EIMPL      = -130,
    OV_EINVAL     = -131,
    OV_ENOTVORBIS = -132,
    OV_EBADHEADER = -133,
    OV_EVERSION   = -134,
    OV_ENOTAUDIO  = -135,
    OV_EBADPACKET = -136,
    OV_EBADLINK   = -137,
    OV_ENOSEEK    = -138,
}

struct OggVorbis_File {
    void* datasource;
    int seekable;
    ogg_int64_t offset;
    ogg_int64_t end;
    ogg_sync_state oy;
    int links;
    ogg_int64_t* offsets;
    ogg_int64_t* dataoffsets;
    c_long* serialnos;
    ogg_int64_t* pcmlengths;
    vorbis_info* vi;
    vorbis_comment* vc;
    ogg_int64_t pcm_offset;
    int ready_state;
    c_long current_serialno;
    int current_link;
    double bittrack;
    double samptrack;
    ogg_stream_state os;
    vorbis_dsp_state vd;
    vorbis_block vb;
    ov_callbacks callbacks;
}

extern(C) @nogc nothrow __gshared:
int ov_clear(OggVorbis_File*);
int ov_fopen(const(char)*, OggVorbis_File*);
int ov_open_callbacks(void* datasource, OggVorbis_File*, const(char)*, c_long, ov_callbacks);
int ov_test_callbacks(void*, OggVorbis_File*, const(char)*, c_long, ov_callbacks);
int ov_test_open(OggVorbis_File*);
c_long ov_bitrate(OggVorbis_File*, int);
c_long ov_bitrate_instant(OggVorbis_File*);
c_long ov_streams(OggVorbis_File*);
c_long ov_seekable(OggVorbis_File*);
c_long ov_serialnumber(OggVorbis_File*, int);
ogg_int64_t ov_raw_total(OggVorbis_File*, int);
ogg_int64_t ov_pcm_total(OggVorbis_File*, int);
double ov_time_total(OggVorbis_File*, int);
int ov_raw_seek(OggVorbis_File*, ogg_int64_t);
int ov_pcm_seek(OggVorbis_File*, ogg_int64_t);
int ov_pcm_seek_page(OggVorbis_File*, ogg_int64_t);
int ov_time_seek(OggVorbis_File*, double);
int ov_time_seek_page(OggVorbis_File*, double);
int ov_raw_seek_lap(OggVorbis_File*, ogg_int64_t);
int ov_pcm_seek_lap(OggVorbis_File*, ogg_int64_t);
int ov_pcm_seek_page_lap(OggVorbis_File*, ogg_int64_t);
int ov_time_seek_lap(OggVorbis_File*, double);
int ov_time_seek_page_lap(OggVorbis_File*, double);
ogg_int64_t ov_raw_tell(OggVorbis_File*);
ogg_int64_t ov_pcm_tell(OggVorbis_File*);
double ov_time_tell(OggVorbis_File*);
vorbis_info* ov_info(OggVorbis_File*, int);
vorbis_comment* ov_comment(OggVorbis_File*, int);
c_long ov_read_float(OggVorbis_File*, float***, int, int*);
c_long ov_read(OggVorbis_File*, byte*, int, int, int, int, int*);
int ov_crosslap(OggVorbis_File*, OggVorbis_File*);
int ov_halfrate(OggVorbis_File*, int);
int ov_halfrate_p(OggVorbis_File*);