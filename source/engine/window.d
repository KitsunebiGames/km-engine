module engine.window;
import bindbc.glfw;

/**
    Static instance of the game window
*/
static Window GameWindow;

/**
    A Window
*/
class Window {
private:
    GLFWwindow* window;

public:
    this(string name) {
        glfwWindowHint(GLFW_CLIENT_API, GLFW_OPENGL_API);
        window = glfwCreateWindow(640, 480, name.ptr, null, null);
    }

    /**
        Close the window
    */
    void close() {
        glfwDestroyWindow(window);
    }
}