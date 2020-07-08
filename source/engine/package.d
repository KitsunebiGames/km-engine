module engine;
public import engine.log;
public import engine.window;

import bindbc.glfw;
import bindbc.opengl;

/**
    Initialize the game engine
*/
void initializeEngine() {

    initGLFW();
    glfwInit();
    AppLog.info("GLFW initialized...");

    initOGL();
    GameWindow = new Window("Kitsune Mahjong");

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
        AppLog.fatal("Could not load GLFW, bad library!");
    } else if (support == GLFWSupport.noLibrary) {
        AppLog.fatal("Could not load GLFW, no library found!");
    }
}

private void initOGL() {
    auto support = loadOpenGL();
    if (support == GLSupport.badLibrary) {
        AppLog.fatal("Could not load OpenGL, bad library!");
    } else if (support == GLSupport.noLibrary) {
        AppLog.fatal("Could not load OpenGL, no library found!");
    }
}