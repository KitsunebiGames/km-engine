/*
    Visual Novel Subsystem

    Copyright © 2020, Luna Nielsen
    Distributed under the 2-Clause BSD License, see LICENSE file.
    
    Authors: Luna Nielsen
*/
module engine.vn;
import engine.vn.render;
import engine.vn.script;
public import engine.vn.character;
public import engine.vn.dialg;
public import engine.vn.script;
import engine;

/**
    Holds the current state of the Visual Novel system
*/
class VNState {
public:
    this() {
        dialogue = new DialogueManager(this);
    }

    /**
        Music being played
    */
    Music music;

    /**
        Ambience loops being played
    */
    Music[] ambience;

    /**
        The background/cg texture
    */
    Texture cg;

    /**
        The list of the characters currently in the scene
    */
    Character[string] characters;

    /**
        The dialogue manager
    */
    DialogueManager dialogue;

    /**
        The current script being executed by the engine
    */
    Script script;

    /**
        Changes the currently active scene
    */
    void changeScene(string scene=null) {
        
        // Clear all the old characters out
        this.characters.clear();

        // Change the scene
        script.changeScene(scene);
    }

    /**
        Cleanup procedure before closing VN state
    */
    void cleanup() {
        import core.memory : GC;

        // Clear all the old characters out
        foreach(name, character; characters) {
            debug AppLog.info("VN Memory Managment", "Destroying %s...", name);
            destroy(character);
        }
        
        // Clear all the old characters out
        this.characters.clear();

        destroy(cg);
        destroy(dialogue);
        destroy(script);

        // Force GC to collect everything
        GC.collect();
    }

    /**
        Sets dialogue auto next flag
    */
    void markAutoNext() {
        dialogue.autoNext = true;
    }

    /**
        Loads the characters defined in a list
    */
    void loadCharacters(string[] characters) {

        // Load characters from the character registry
        foreach(character; characters) {
            this.characters[character] = CharacterRegistry.create(character);
        }
    }

    /**
        Loads a script
    */
    void loadScript(Scene[string] manuscript) {
        this.script = new Script(this, manuscript);
        script.runNext();
    }

    /**
        Updates the visual novel
    */
    void update() {

        // No need to update when there's no manuscript loaded
        if (script is null) return;
        
        // If the "Confirm" binding or left mouse button was pressed, advance dialogue
        if (Input.wasPressed("Confirm") || Mouse.isButtonClicked(MouseButton.Left)) {
            
            // AutoNext dialogue cannot be skipped
            // Note: AutoNext dialogue should be brief
            if (!dialogue.autoNext) {
                if (!dialogue.done) {
                    dialogue.skip();
                } else {
                    script.runNext();
                }
            }
        }

        // Handle AutoNext dialogue
        if (dialogue.autoNext) {
            if (dialogue.done()) {
                dialogue.autoNext = false;
                script.runNext();
            }
        }

        // Update the characters
        foreach(character; characters) {
            character.update();
        }

        // Update the dialogue manager
        dialogue.update();

        // Cleanup
        foreach(amb; ambience) {
            if (!amb.isPlaying) {
                destroy(amb);
            }
        }
    }

    /**
        Draw's the visual novel
    */
    void draw() {

        // If there's no manuscript then we don't need to try to draw stuff
        if (script is null) {
            GameFont.changeSize(48);
            GameFont.draw("No manuscripts are loaded!"d, vec2(16, 16));
            GameFont.flush();
            return;
        }

        // First draw background/cg
        if (cg !is null) {
            GameBatch.draw(cg, vec4(0, 0, kmCameraViewWidth, kmCameraViewHeight));
            GameBatch.flush();
        }

        // Draw the characters
        foreach(character; characters) {
            character.draw();
        }

        // Draw dialogue
        dialogue.draw();
    }
}

shared static this() {
    Input.registerKey("Confirm", Key.KeySpace);
}