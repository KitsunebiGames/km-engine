/*
    Copyright © 2020, Luna Nielsen
    Distributed under the 2-Clause BSD License, see LICENSE file.
    
    Authors: Luna Nielsen
*/
module engine;
public import engine.core;
public import engine.input;
public import engine.render;
public import engine.math;

import bindbc.glfw;

/**
    Initialize the game engine
*/
void initEngine() {

    // Initialize GLFW
    initGLFW();
    glfwInit();
    AppLog.info("Engine", "GLFW initialized...");

    // Create window
    GameWindow = new Window();
    GameWindow.makeCurrent();
    AppLog.info("Engine", "Window initialized...");

    // Initialize OpenGL and make context current
    initOGL();
    AppLog.info("Engine", "OpenGL initialized...");

    // Initialzie input
    initInput(GameWindow.winPtr);
    AppLog.info("Engine", "Input system initialized...");
}

/**
    Closes the engine and relases libraries, etc.
*/
void closeEngine() {
    glfwTerminate();
    unloadGLFW();
    unloadOpenGL();
}

private void initGLFW() {
    auto support = loadGLFW();
    if (support == GLFWSupport.badLibrary) {
        AppLog.fatal("Engine", "Could not load GLFW, bad library!");
    } else if (support == GLFWSupport.noLibrary) {
        AppLog.fatal("Engine", "Could not load GLFW, no library found!");
    }
}

private void initOGL() {
    auto support = loadOpenGL();
    if (support == GLSupport.badLibrary) {
        AppLog.fatal("Engine", "Could not load OpenGL, bad library!");
    } else if (support == GLSupport.noLibrary) {
        AppLog.fatal("Engine", "Could not load OpenGL, no library found!");
    } else if (support == GLSupport.noContext) {
        AppLog.fatal("Engine", "OpenGL context was not created before loading OpenGL.");
    }
}