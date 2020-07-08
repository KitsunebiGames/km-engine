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
    string title_;
    int width;
    int height;

public:

    /**
        Destructor
    */
    ~this() {
        glfwDestroyWindow(window);
    }

    /**
        Constructor
    */
    this(string title = "KitsuneMahjongEngine", int width = 640, int height = 480) {
        this.title_ = title;
        this.width = width;
        this.height = height;

        glfwWindowHint(GLFW_SAMPLES, 4);
        glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
        glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
        glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GLFW_TRUE); // To make macOS happy
        glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
        window = glfwCreateWindow(640, 480, this.title_.ptr, null, null);
        
    }

    /**
        Hides the window
    */
    void hide() {
        glfwHideWindow(window);
    }

    /**
        Show window
    */
    void show() {
        glfwShowWindow(window);
    }

    /**
        Gets the title of the window
    */
    @property string title() {
        return this.title_;
    }

    /**
        Sets the title of the window
    */
    @property void title(string value) {
        this.title_ = value;
        glfwSetWindowTitle(window, this.title_.ptr);
    }

    /**
        poll for new window events
    */
    void pollEvents() {
        glfwPollEvents();
    }

    /**
        Set the close request flag
    */
    void close() {
        glfwSetWindowShouldClose(window, 1);
    }

    /**
        Gets whether the window has requested to close (aka the game is requested to exit)
    */
    bool isExitRequested() {
        return cast(bool)glfwWindowShouldClose(window);
    }

    /**
        Makes the OpenGL context of the window current
    */
    void makeCurrent() {
        glfwMakeContextCurrent(window);
    }

    /**
        Swaps the OpenGL buffers for the window
    */
    void swapBuffers() {
        glfwSwapBuffers(window);
    }

    /**
        Sets the swap interval, by default vsync
    */
    void setSwapInterval(SwapInterval interval = SwapInterval.VSync) {
        glfwSwapInterval(cast(int)interval);
    }

    /**
        Gets the glfw window pointer
    */
    GLFWwindow* winPtr() {
        return window;
    }
}

/**
    A swap interval
*/
enum SwapInterval : int {
    Unlimited = 0,
    VSync = 1
}