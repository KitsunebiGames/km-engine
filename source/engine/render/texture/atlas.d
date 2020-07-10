/*
    Copyright © 2020, Luna Nielsen
    Distributed under the 2-Clause BSD License, see LICENSE file.
    
    Authors: Luna Nielsen
*/
module engine.render.texture.atlas;
import engine.render.texture;
import gl3n.linalg;
import std.exception;
import std.format;
import engine;

/**
    The game's static texture atlas collection
*/
static AtlasCollection GameAtlas;

/**
    An index in the atlas collection
    
    It is safe to keep this value around for caching
*/
struct AtlasIndex {
private:
    TextureAtlas parentAtlas;

public:
    /**
        The UV points of the texture
    */
    vec4 uv;

    /**
        Bind the atlas texture
    */
    void bind(uint unit = 0) {
        parentAtlas.bind(unit);
    }
}

/***/
class AtlasCollection {
private:
    TextureAtlas[] atlasses;
    AtlasIndex[string] texTable;

public:
    /**
        Gets the uv and atlas pointer for the index
    */
    AtlasIndex opIndex(string name) {
        return texTable[name];
    }

    /**
        Add texture to the atlas from a file
    */
    void add(string name, string file, size_t atlas=0) {
        add(name, ShallowTexture(file), atlas);
    }

    /**
        Add texture to the atlas collection
    */
    void add(string name, ShallowTexture shallowTexture, size_t atlas=0) {
        enforce(name !in texTable, "Texture with name '%s' is already in the atlas collection".format(name));

        // Add new atlas
        if (atlas >= atlasses.length) {
            AppLog.info("AtlasCollection", "All atlases were out of space, creating new atlas %s...", atlasses.length);
            atlasses ~= new TextureAtlas(vec2i(4096, 4096));
        }

        // Add to atlas and get uvs
        vec4 uvs = atlasses[atlas].add(name, shallowTexture);

        // Height is 0 if it couldn't fit
        if (uvs.w == 0) {

            // Try the next atlas
            add(name, shallowTexture, atlas+1);
            return;
        }

        // Put the texture and its uvs in to the table
        texTable[name] = AtlasIndex(atlasses[atlas], uvs);

    }
}

/**
    A texture atlas
*/
class TextureAtlas {
private:
    Texture texture;
    TexturePacker packer;
    vec4[string] entries;

public:

    /**
        Creates a new texture atlas
    */
    this(vec2i textureSize) {
        texture = new Texture(textureSize.x, textureSize.y);
        packer = new TexturePacker(textureSize);
    }

    /**
        Gets the UV points for the index
    */
    vec4 opIndex(string name) {
        return entries[name];
    }

    /**
        Bind the atlas texture
    */
    void bind(uint unit = 0) {
        texture.bind(unit);
    }

    /**
        Add texture to the atlas from a file
    */
    void add(string name, string file) {
        add(name, ShallowTexture(file));
    }

    /**
        Add texture to the atlas
    */
    vec4 add(string name, ShallowTexture shallowTexture) {
        enforce(name !in entries, "Texture with name '%s' is already in the atlas".format(name));

        // Get packing position of texture
        vec4i texpos = packer.packTexture(vec2i(shallowTexture.width, shallowTexture.height));

        // Texture does not fit in this atlas.
        if (texpos.w == 0) return vec4(0, 0, 0, 0);

        // Put it in to the texture and set its entry
        texture.setDataRegion(shallowTexture.data, texpos.x, texpos.y, shallowTexture.width, shallowTexture.height);

        AppLog.info("debug", "Packed texture %s in to region (%s, %s, %s, %s)", name, texpos.x, texpos.y, shallowTexture.width, shallowTexture.height);

        // Calculate UV coordinates and put them in to the table
        vec2 texSize = vec2(cast(float)texture.width, cast(float)texture.height);
        vec4 uvPoints = vec4(
            (cast(float)texpos.x)/texSize.x,
            (cast(float)texpos.y)/texSize.y, 
            (cast(float)texpos.x+shallowTexture.width)/texSize.x, 
            (cast(float)texpos.y+shallowTexture.height)/texSize.y
        );

        // Adjust UV points to avoid oversampling
        uvPoints.x += 0.2/texSize.x;
        uvPoints.y += 0.2/texSize.y;
        uvPoints.z -= 0.2/texSize.x;
        uvPoints.w -= 0.2/texSize.y;
        entries[name] = uvPoints;
        return uvPoints;
    }
}