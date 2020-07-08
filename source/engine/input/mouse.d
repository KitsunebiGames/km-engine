/*
    Copyright © 2020, Luna Nielsen
    Distributed under the 2-Clause BSD License, see LICENSE file.
    
    Authors: Luna Nielsen
*/
module engine.input.mouse;
import engine.input;
import bindbc.glfw;
import gl3n.linalg;

/**
    The buttons on a mouse
*/
enum MouseButton {
    Left = GLFW_MOUSE_BUTTON_LEFT,
    Middle = GLFW_MOUSE_BUTTON_MIDDLE,
    Right = GLFW_MOUSE_BUTTON_RIGHT
}

/**
    Mouse
*/
class Mouse {
private static:
    GLFWwindow* window;

public static:

    /**
        Constructs the underlying data needed
    */
    void initialize(GLFWwindow* window) {
        this.window = window;
    }

    /**
        Gets mouse position
    */
    vec2 position() {
        double x, y;
        glfwGetCursorPos(window, &x, &y);
        return vec2(cast(float)x, cast(float)y);
    }

    /**
        Gets if a mouse button is pressed
    */
    bool isButtonPressed(MouseButton button) {
        return glfwGetMouseButton(window, button) == GLFW_PRESS;
    }

    /**
        Gets if a mouse button is released
    */
    bool isButtonPressed(MouseButton button) {
        return glfwGetMouseButton(window, button) == GLFW_RELEASE;
    }
}