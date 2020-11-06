/*
    UI Subsystem

    Copyright © 2020, Luna Nielsen
    Distributed under the 2-Clause BSD License, see LICENSE file.
    
    Authors: Luna Nielsen
*/
module engine.ui;
public import engine.ui.widget;
import engine;
import bindbc.opengl;
import core.memory;

/**
    Base stuff for UI rendering
*/
class UI {
public:

    /**
        Sets up state for UI rendering
    */
    static void begin() {
        glEnable(GL_SCISSOR_TEST);
    }

    /**
        Set the UI scissor area
    */
    static void setScissor(vec4i scissor) {
        glScissor(scissor.x, (GameWindow.height-scissor.y)-scissor.w, cast(uint)scissor.z, cast(uint)scissor.w);
    }

    /**
        Finishes up UI rendering state
    */
    static void end() {
        glDisable(GL_SCISSOR_TEST);
    }
}