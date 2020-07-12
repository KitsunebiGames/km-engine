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

package(engine.render):
    Texture texture() {
        return parentAtlas.texture;
    }

public:
    /**
        The UV points of the texture
    */
    vec4 uv;

    /**
        The area of the texture in the atlas
    */
    vec4 area;

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
    Filtering defaultFilter = Filtering.Point;

public:
    /**
        Gets the uv and atlas pointer for the index
    */
    AtlasIndex opIndex(string name) {
        return texTable[name];
    }

    /**
        Gets whether the atlas has the specified name
    */
    bool has(string name) {
        return (name in texTable) !is null;
    }

    /**
        Add texture to the atlas from a file
    */
    void add(string name, string file, size_t atlas=0) {
        add(name, ShallowTexture(file), atlas);
    }
    
    /**
        Sets the filtering mode for the collection
    */
    void setFiltering(Filtering filtering) {
        defaultFilter = filtering;
        foreach(atlas; atlasses) {
            atlas.setFiltering(filtering);
        }
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
            atlasses[$-1].setFiltering(defaultFilter);
        }

        // Add to atlas and get uvs
        AtlasArea area = atlasses[atlas].add(name, shallowTexture);

        // Height is 0 if it couldn't fit
        if (!area.area.isFinite) {

            // Try the next atlas
            add(name, shallowTexture, atlas+1);
            return;
        }

        // Put the texture and its uvs in to the table
        texTable[name] = AtlasIndex(atlasses[atlas], area.uv, area.area);

    }
}

/**
    An area in a texture atlas
*/
struct AtlasArea {
    /**
        The area in pixels
    */
    vec4 area;

    /**
        The UV coordinates
    */
    vec4 uv;
}

/**
    A texture atlas
*/
class TextureAtlas {
package(engine.render):
    Texture texture;

private:
    TexturePacker packer;
    AtlasArea[string] entries;

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
    AtlasArea opIndex(string name) {
        return entries[name];
    }

    /**
        Bind the atlas texture
    */
    void bind(uint unit = 0) {
        texture.bind(unit);
    }

    /**
        Set filtering used for the texture
    */
    void setFiltering(Filtering filtering) {
        texture.setFiltering(filtering);
    }

    /**
        Add texture to the atlas from a file
    */
    AtlasArea add(string name, string file) {
        return add(name, ShallowTexture(file));
    }

    /**
        Add texture to the atlas
    */
    AtlasArea add(string name, ShallowTexture shallowTexture) {
        enforce(name !in entries, "Texture with name '%s' is already in the atlas".format(name));

        // Get packing position of texture
        vec4i texpos = packer.packTexture(vec2i(shallowTexture.width, shallowTexture.height));

        // Texture does not fit in this atlas.
        if (!texpos.isFinite) return AtlasArea(vec4.init, vec4.init);

        // Put it in to the texture and set its entry
        texture.setDataRegion(shallowTexture.data, texpos.x, texpos.y, shallowTexture.width, shallowTexture.height);

        debug {
            AppLog.info("debug", "Packed texture %s in to region (%s, %s, %s, %s)", name, texpos.x, texpos.y, shallowTexture.width, shallowTexture.height);
        }

        // Calculate UV coordinates and put them in to the table
        vec2 texSize = vec2(cast(float)texture.width, cast(float)texture.height);
        vec4 texArea = vec4(
            texpos.x, 
            texpos.y, 
            shallowTexture.width,
            shallowTexture.height
        );

        vec4 uvPoints = vec4(
            texArea.x/texSize.x,
            texArea.y/texSize.y, 
            (texArea.x+texArea.z)/texSize.x, 
            (texArea.y+texArea.w)/texSize.y
        );

        // Adjust UV points to avoid oversampling
        uvPoints.x += 0.25/texSize.x;
        uvPoints.y += 0.25/texSize.y;
        uvPoints.z -= 0.25/texSize.x;
        uvPoints.w -= 0.25/texSize.y;
        entries[name] = AtlasArea(texArea, uvPoints);
        return entries[name];
    }

    /**
        Remove an entry from the atlas
    */
    void remove(string name) {
        packer.remove(vec4i(
                cast(int)entries[name].area.x, 
                cast(int)entries[name].area.y, 
                cast(int)entries[name].area.z, 
                cast(int)entries[name].area.w
            )
        );
        entries.remove(name);
    }

    /**
        Clears the texture atlas
    */
    void clear() {
        packer.clear();
        entries.clear();
    }
}