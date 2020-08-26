/*
    Input Handling Subsystem

    Copyright © 2020, Luna Nielsen
    Distributed under the 2-Clause BSD License, see LICENSE file.
    
    Authors: Luna Nielsen
*/
module engine.input;
import bindbc.glfw;

public import engine.input.keyboard;
public import engine.input.mouse;

/**
    Initializes input system
*/
void initInput(GLFWwindow* window) {

    // Initialize keyboard
    Keyboard.initialize(window);

    // Initialize mouse
    Mouse.initialize(window);
}