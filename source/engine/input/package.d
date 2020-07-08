/*
    Copyright © 2020, Luna Nielsen
    Distributed under the 2-Clause BSD License, see LICENSE file.
    
    Authors: Luna Nielsen
*/
module engine.input;
import bindbc.glfw;

public import engine.input.keyboard;

/**
    Initializes input system
*/
void initInput(GLFWwindow* window) {

    // Initialize keyboard
    Keyboard.initialize(window);
}