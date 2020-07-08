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