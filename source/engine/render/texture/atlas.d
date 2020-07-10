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
    void add(string name, ShallowTexture shallowTexture) {
        enforce(name !in entries, "Texture with name '%s' is already in the atlas".format(name));

        // Get packing position of texture
        vec2i texpos = packer.packTexture(shallowTexture.data, vec2i(shallowTexture.width, shallowTexture.height));

        // Put it in to the texture and set its entry
        texture.setDataRegion(shallowTexture.data, texpos.x, texpos.y, shallowTexture.width, shallowTexture.height);


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
    }
}