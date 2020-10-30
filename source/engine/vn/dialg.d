/*
    Copyright © 2020, Luna Nielsen
    Distributed under the 2-Clause BSD License, see LICENSE file.
    
    Authors: Luna Nielsen
*/
module engine.vn.dialg;
import engine.vn.render.dialg;
import engine.vn.log;
import engine.vn;
import engine;

/**
    Manager for dialogue
*/
class DialogueManager {
private:
    DialogueRenderer renderer;
    string speaker;
    dstring dspeaker;
    VNLog log;
    VNState state;

public:
    this(VNState state) {
        this.state = state;

        log = new VNLog();
        renderer = new DialogueRenderer();
        if (!GameAtlas.has("ui_vnbar")) {
            GameAtlas.add("ui_vnbar", "assets/textures/ui/vn-bar.png");
        }
    }

    /**
        Whether the hide the dialogue box
    */
    bool hide = false;

    /**
        Whether the dialogue requested to automatically advance
    */
    bool autoNext = false;

    /**
        Whether the text is done scrolling
    */
    bool done() {
        return renderer.done;
    }

    /**
        Skip to end of text
    */
    void skip() {
        renderer.skip();
    }

    /**
        Update the dialogue manager
    */
    void update() {
        renderer.update();
    }

    /**
        Push dialogue/action to the renderer
        Automatically pu
    */
    void push(dstring dialogue, dstring origin = null) {
        speaker = origin.toDString;
        dspeaker = origin;
        renderer.pushText(dialogue);
        log.add(origin, dialogue);
    }

    /**
        Draw dialogue box
    */
    void draw() {
        if (hide) return;

        // Set font size
        UI.UIFont.changeSize(48);

        // Draw the bar
        GameBatch.draw("ui_vnbar", vec4(0, 1080-292, 1920, 292));
        GameBatch.flush();

        // Draw name tag
        if (speaker.length > 0) {
            UI.UIFont.draw(
                speaker in state.characters ? 
                state.characters[speaker].displayName : 
                dspeaker, 
                vec2(32, 804)
            );
        }
        UI.UIFont.flush();

        // Slow type the dialogue
        renderer.draw(vec2(48, 900));
    }
}