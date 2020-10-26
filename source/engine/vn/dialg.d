/*
    Copyright © 2020, Luna Nielsen
    Distributed under the 2-Clause BSD License, see LICENSE file.
    
    Authors: Luna Nielsen
*/
module engine.vn.dialg;
import engine.vn.render.dialg;
import engine;

/**
    Manager for dialogue
*/
class DialogueManager {
private:
    DialogueRenderer renderer;
    dstring speaker;

public:
    this(string barTexture) {
        renderer = new DialogueRenderer();
        if (!GameAtlas.has("ui_vnbar")) {
            GameAtlas.add("ui_vnbar", barTexture);
        }
    }

    /**
        Whether the hide the dialogue box
    */
    bool hide = false;

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

    void push(dstring origin, dstring dialogue) {
        speaker = origin;
        renderer.pushText(dialogue);
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
        if (speaker.length > 0) UI.UIFont.draw(speaker, vec2(32, 804));
        UI.UIFont.flush();

        // Slow type the dialogue
        renderer.draw(vec2(48, 900));
    }
}