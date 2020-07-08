module engine;
public import engine.log;
public import engine.window;
public import engine.input;

import bindbc.glfw;
import bindbc.opengl;

/**
    Initialize the game engine
*/
void initEngine() {

    initGLFW();
    glfwInit();
    AppLog.info("Engine", "GLFW initialized...");

    initOGL();
    GameWindow = new Window();
    AppLog.info("Engine", "Window initialized...");

    GameWindow.makeCurrent();

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
    }
}