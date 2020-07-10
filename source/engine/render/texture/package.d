/*
    Copyright © 2020, Luna Nielsen
    Distributed under the 2-Clause BSD License, see LICENSE file.
    
    Authors: Luna Nielsen
*/
module engine.render.texture;
public import engine.render.texture.packer;
public import engine.render.texture.atlas;
import bindbc.opengl;
import std.exception;
import imagefmt;

/**
    Filtering mode for texture
*/
enum Filtering {
    /**
        Linear filtering will try to smooth out textures
    */
    Linear = GL_LINEAR,

    /**
        Point filtering will try to preserve pixel edges.
        Due to texture sampling being float based this is imprecise.
    */
    Point = GL_POINT
}

/**
    Texture wrapping modes
*/
enum Wrapping {
    /**
        Clamp texture sampling to be within the texture
    */
    Clamp = GL_CLAMP_TO_BORDER,

    /**
        Wrap the texture in every direction idefinitely
    */
    Repeat = GL_REPEAT,

    /**
        Wrap the texture mirrored in every direction indefinitely
    */
    Mirror = GL_MIRRORED_REPEAT
}

/**
    A texture which is not bound to an OpenGL context

    Used for texture atlassing
*/
struct ShallowTexture {
public:
    /**
        8-bit RGBA color data
    */
    ubyte[] data;

    /**
        Width of texture
    */
    int width;

    /**
        Height of texture
    */
    int height;

    /**
        Loads a shallow texture from image file
        Supported file types:
        * PNG 8-bit
        * BMP 8-bit
        * TGA 8-bit non-palleted
        * JPEG baseline
    */
    this(string file) {

        // Load image from disk, as RGBA 8-bit
        IFImage image = read_image(file, 4, 8);
        enforce( image.e == 0, IF_ERROR[image.e]);
        scope(exit) image.free();

        // Copy data from IFImage to this ShallowTexture
        this.data = new ubyte[image.buf8.length];
        this.data[] = image.buf8;

        // Set the width/height data
        this.width = image.w;
        this.height = image.w;
    }
}

/**
    A texture, only format supported is unsigned 8 bit RGBA
*/
class Texture {
private:
    GLuint id;
    int width;
    int height;

public:

    /**
        Loads texture from image file
        Supported file types:
        * PNG 8-bit
        * BMP 8-bit
        * TGA 8-bit non-palleted
        * JPEG baseline
    */
    this(string file) {

        // Load image from disk, as RGBA 8-bit
        IFImage image = read_image(file, 4, 8);
        enforce( image.e == 0, IF_ERROR[image.e]);
        scope(exit) image.free();

        // Load in image data to OpenGL
        this(image.buf8, image.w, image.h);
    }

    /**
        Creates a texture from a ShallowTexture
    */
    this(ShallowTexture shallow) {
        this(shallow.data, shallow.width, shallow.height);
    }

    /**
        Creates a new empty texture
    */
    this(int width, int height) {

        // Create an empty texture array with no data
        ubyte[] empty = new ubyte[width*height*4];

        // Pass it on to the other texturing
        this(empty, width, height);
    }

    /**
        Creates a new texture from specified data
    */
    this(ubyte[] data, int width, int height) {
        this.width = width;
        this.height = height;
        
        // Generate OpenGL texture
        glGenTextures(1, &id);
        this.setData(data);

        // Set default filtering and wrapping
        this.setFiltering(Filtering.Point);
        this.setWrapping(Wrapping.Clamp);
    }

    /**
        Set the filtering mode used for the texture
    */
    void setFiltering(Filtering filtering) {
        this.bind();
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, filtering);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, filtering);
    }

    /**
        Set the wrapping mode used for the texture
    */
    void setWrapping(Wrapping wrapping) {
        this.bind();
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, wrapping);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, wrapping);
    }

    /**
        Sets the data of the texture
    */
    void setData(ubyte[] data) {
        this.bind();
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, data.ptr);
    }

    /**
        Sets a region of a texture to new data
    */
    void setDataRegion(ubyte[] data, int x, int y, int width, int height) {
        this.bind();

        // Make sure we don't try to change the texture in an out of bounds area.
        enforce( x >= 0 && x+width < this.width, "x offset is out of bounds");
        enforce( y >= 0 && y+height < this.height, "y offset is out of bounds");

        // Update the texture
        glTexSubImage2D(GL_TEXTURE_2D, 0, x, y, width, height, GL_RGBA, GL_UNSIGNED_BYTE, data.ptr);
    }

    /**
        Bind this texture
        
        Notes
        - In release mode the unit value is clamped to 31 (The max OpenGL texture unit value)
        - In debug mode unit values over 31 will assert.
    */
    void bind(uint unit = 0) {
        assert(unit > 31u, "Outside maximum OpenGL texture unit value");
        glActiveTexture(GL_TEXTURE0+(unit <= 31u ? unit : 31u));
        glBindTexture(GL_TEXTURE_2D, id);
    }
}