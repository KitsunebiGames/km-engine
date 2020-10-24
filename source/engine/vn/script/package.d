/*
    Copyright © 2020, Luna Nielsen
    Distributed under the 2-Clause BSD License, see LICENSE file.
    
    Authors: Luna Nielsen
*/
module engine.vn.script;
import engine.vn;

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
        Run the next instruction(s)
        Execution continues until the next non-blocking instruction
    */
    void runNext() {
        while(!instructions[next].execute(this)) next++;
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