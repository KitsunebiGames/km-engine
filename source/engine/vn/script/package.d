/*
    Copyright © 2020, Luna Nielsen
    Distributed under the 2-Clause BSD License, see LICENSE file.
    
    Authors: Luna Nielsen
*/
module engine.vn.script;
import engine.vn;
public import engine.vn.script.instr;

/**
    A bookmark to where in the script to continue from (for saving)
*/
struct Bookmark {
    /**
        The scene current being shown
    */
    string scene;

    /**
        The last blocking line + 1
    */
    int line;
}

/**
    A visual novel script
*/
class Script {
private:
    /**
        Manuscript holder
    */
    Scene[string] manuscripts;

    /**
        Execution offset.
    */
    int next;

    /**
        Current instruction
    */
    int current() { return next-1; }

    /**
        The current scene
    */
    string currentScene;

    /**
        Returns the current instruction list
    */
    IScriptInstr[] instructions() { return manuscripts[currentScene].instructions; }

public:

    /**
        The state of the visual novel
    */
    VNState state;

    /**
        Destructor
    */
    ~this() {
        next = -1;
        manuscripts.clear();
    }

    /**
        Constructs a new script
        Always runs the "main" scene
    */
    this(VNState state, Scene[string] manuscript) {
        this.state = state;
        manuscripts = manuscript;
        this.changeScene("main");
    }

    /**
        Changes the scene
    */
    void changeScene(string scene) {
        currentScene = scene;
        next = 0;
        state.loadCharacters(manuscripts[currentScene].characters);
    }

    /**
        Run the next instruction(s)
        Execution continues until the next non-blocking instruction
    */
    void runNext() {
        while(!instructions[next].execute(this)) {
            next++;
            
            // Loop if we're at the end of the instructions
            if (next >= instructions.length) {
                next = 0;
                runNext();
                return;
            }
        }
        next++;

        // Loop if we're at the end of the instructions
        if (next >= instructions.length) {
            next = 0;
            return;
        }
    }

    /**
        Gets a bookmark
    */
    Bookmark bookmark() {

        // Count back instructions to the last blocking instruction
        int c = current();
        if (c >= 1) {
            while (!instructions[c].isBlocking) {

                // Make sure we don't go *too* far back
                if (c >= 1) c--;
                else break;
            }
        }
        
        // Cap to first instruction if we went under instruction 0
        if (c < 0) c = 0;

        return Bookmark(
            currentScene,
            c+1 // We want to return the instruction *after* the last blocking one
        );
    }
}

/**
    A scene in the VN
*/
class Scene {
public:

    /**
        Creates a new scene
    */
    this(string[] characters, IScriptInstr[] instructions) {
        this.characters = characters;
        this.instructions = instructions;
    }

    /**
        The characters to be loaded in this scene
    */
    string[] characters;

    /**
        The instructions associated with a scene
    */
    IScriptInstr[] instructions;
}

/**
    A script instruction
*/
interface IScriptInstr {

    /**
        Execution function that runs the instruction
    */
    bool execute(Script script);

    /**
        Gets whether the instruction is blocking
    */
    bool isBlocking();
}