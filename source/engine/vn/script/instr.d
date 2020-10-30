/*
    Copyright © 2020, Luna Nielsen
    Distributed under the 2-Clause BSD License, see LICENSE file.
    
    Authors: Luna Nielsen
*/
module engine.vn.script.instr;
import engine.vn.script;
import engine;

/**
    Instruction that shows a character
*/
class CGInstr : IScriptInstr {
public:
    string cgfile;
    
    this(string cgfile = null) {
        this.cgfile = cgfile;
    }

    bool execute(Script script) {
        script.state.cg = cgfile is null ? null : new Texture("assets/textures/backgrounds/"~cgfile);
        return false;
    }

    bool isBlocking() {
        return false;
    }
}

/**
    Instruction that plays a sound effect
*/
class SFXInstr : IScriptInstr {
public:
    string sfxfile;
    
    this(string sfxfile) {
        this.sfxfile = sfxfile;
    }

    bool execute(Script script) {
        (new Sound(sfxfile)).play();
        return false;
    }

    bool isBlocking() {
        return false;
    }
}

/**
    Instruction that sets the scene's music
*/
class MusicInstr : IScriptInstr {
public:
    string musicFile;
    
    this(string musicFile) {
        this.musicFile = musicFile;
    }

    bool execute(Script script) {
        if (script.state.music !is null) {
            script.state.music.stop();
        }
        script.state.music = new Music(musicFile);
        script.state.music.setLooping(true);
        script.state.music.play();
        return false;
    }

    bool isBlocking() {
        return false;
    }
}

/**
    Instruction that shows a character
*/
class ShowInstr : IScriptInstr {
public:
    bool side;
    string texture;
    string character;
    
    this(string character, string texture=null, bool side=false) {
        this.character = character;
        this.texture = texture;
        this.side = side;
    }

    bool execute(Script script) {
        if (character in script.state.characters) {
            script.state.characters[character].shown = true;
        
            if (texture !is null) {
                script.state.characters[character].setTexture(texture);
            }

            script.state.characters[character].position = !side ?
                vec2(256, 1080) : vec2(1920-256, 1080);
            script.state.characters[character].isFlipped = side;
        }
        return false;
    }

    bool isBlocking() {
        return false;
    }
}

/**
    Instruction that hides a character
*/
class HideInstr : IScriptInstr {
public:
    string character;
    
    this(string character) {
        this.character = character;
    }

    bool execute(Script script) {
        if (character in script.state.characters) {
            script.state.characters[character].shown = false;
        }
        return false;
    }

    bool isBlocking() {
        return false;
    }
}

/**
    Instruction that causes a character to say something
*/
class SayInstr : IScriptInstr {
public:
    bool show;
    string origin;
    string text;

    this(string text, string origin=null, bool show=false) {
        this.origin = origin;
        this.text = text;
        this.show = show;
    }

    /**
        Executes the instruction
    */
    bool execute(Script script) {
        script.state.dialogue.push(text.toEngineString(), origin.toEngineString());

        // If show is enabled show the character
        if (origin in script.state.characters) {

            // Activates the character
            script.state.characters[origin].activate();

            if (show) {
                script.state.characters[origin].shown = true;
            }
        }
        return true;
    }

    bool isBlocking() {
        return true;
    }
}
/**
    Instruction that causes a character to say something, this is nonblocking
*/
class NSayInstr : SayInstr {
public:
    bool show;
    string origin;
    string text;

    this(string text, string origin=null, bool show=false) {
        super(text, origin, show);
    }

    /**
        Executes the instruction
    */
    override bool execute(Script script) {
        script.state.markAutoNext();
        return super.execute(script);
    }

    override bool isBlocking() {
        return super.isBlocking();
    }
}

/**
    Instruction that executes D code
*/
class CodeInstr : IScriptInstr {
public:
    void delegate(Script script) instr;

    this(void delegate(Script script) instr) {
        this.instr = instr;
    }

    /**
        Executes the instruction
    */
    bool execute(Script script) {
        instr(script);
        return false;
    }

    bool isBlocking() {
        return false;
    }
}