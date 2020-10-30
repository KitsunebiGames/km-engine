/*
    Copyright © 2020, Luna Nielsen
    Distributed under the 2-Clause BSD License, see LICENSE file.
    
    Authors: Luna Nielsen
*/
module engine.vn.character;
import engine.vn.render;
import engine;
import std.format;

/**
    Character declaration
*/
struct CharDecl {
    /**
        The symbolic name for the character
    */
    string name;

    /**
        Name of character
    */
    dstring[string] names;

    /**
        Textures for character
    */
    string[string] textures;
}

/**
    Character registry
*/
class CharacterRegistry {
private static:
    CharDecl[string] registry;

public static:
    /**
        Register a character
    */
    public void register(string name, CharDecl declaration) {
        registry[name] = declaration;
    }

    /**
        Create a character from its name
    */
    public Character create(string name) {
        return new Character(registry[name]);
    }
}

/**
    A character in the visual novel
*/
class Character {
private:

    /**
        The system name of the character
    */
    string name;

    /**
        All the names the character can have
    */
    dstring[string] dnames;

    /**
        Named textures for the character
    */
    AtlasIndex[string] textures;

    /**
        The texture of the character
    */
    string texture;

    /**
        Cached texture size
    */
    vec2 textureSize;

    /**
        How visible the character is
    */
    float visibility = 0;

public:

    dstring displayName() {
        return dnames[CurrentLanguage];
    }

    /**
        Whether to show the character
    */
    bool shown;

    /**
        Position of the character on the screen
    */
    vec2 position;

    /**
        Whether the character's texture is flipped vertically
    */
    bool isFlipped;

    /**
        The current texture
    */
    AtlasIndex* currentTexture() {
        return texture in textures;
    }

    /**
        Sets the character's texture
    */
    void setTexture(string texture) {
        this.texture = texture;
        this.textureSize = currentTexture.area.zw;
    }

    /**
        Creates a character from a definition
    */
    this(CharDecl decl) {
        this.name = decl.name;
        this.dnames = decl.names;
        foreach (texName, texture; decl.textures) {
            AppLog.info("VN Engine", "Added character texture %s", texName);
            GameAtlas.add(genTexName(name, texName), texture);
            textures[texName] = GameAtlas[genTexName(name, texName)];
        }

        // Set texture to neutral if any was given for the character
        if (decl.textures.length > 0) this.setTexture("neutral");
    }

    /**
        Clean up textures between scene switches.
    */
    ~this() {

        // Remove unused textures from the atlas
        foreach(texName, _; textures) {
            GameAtlas.remove(genTexName(name, texName));
        }
    }

    /**
        Activates the character causing them to jump if visible
    */
    private float activationTimer = 0.0;
    private float jump = 0;
    void activate() {
        activationTimer = 1;
    }

    void update() {

        // Handle visibility fade
        if (shown) {
            if (visibility < 1) visibility += 10*deltaTime();
            if (visibility > 1) visibility = 1;
        } else {
            if (visibility > 0) visibility -= 10*deltaTime();
            if (visibility < 0) visibility = 0;
        }

        // TODO: use the animation system for this

        // Handle activation timer countdown
        if (activationTimer > 0) activationTimer -= 5*deltaTime();
        if (activationTimer < 0) activationTimer = 0;

        if (activationTimer > 0.5) {
            float t = (0.5-activationTimer)*2;
            jump = lerp!float(-12, 0, t); 
        } else {
            float t = (0.5-activationTimer)*2;
            jump = lerp!float(0, -12, t); 
        }
    }

    void draw() {
        if (!shown && visibility == 0) return;
        if (currentTexture is null) return;
        GameBatch.draw(
            *currentTexture, 
            vec4(position.x, position.y-jump, textureSize.x, textureSize.y), 
            vec4.init, 
            vec2(textureSize.x/2, textureSize.y),
            0,
            isFlipped ? SpriteFlip.Horizontal : SpriteFlip.None,
            vec4(1, 1, 1, visibility)
        );
    }
}

private string genTexName(string charName, string texName) {
    return "%s/%s".format(charName, texName);
}