/*
    Copyright © 2020, Luna Nielsen
    Distributed under the 2-Clause BSD License, see LICENSE file.
    
    Authors: Luna Nielsen
*/
module engine.core.window;
import bindbc.glfw;
import bindbc.opengl;

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
    int width_;
    int height_;

    int fbWidth;
    int fbHeight;

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
        this.width_ = width;
        this.height_ = height;
        this.fbWidth = width;
        this.fbHeight = height;

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
        Gets the width of the window's framebuffer
    */
    @property int width() {
        return this.fbWidth;
    }

    /**
        Gets the height of the window's framebuffer
    */
    @property int height() {
        return this.fbHeight;
    }

    /**
        poll for new window events
    */
    void update() {
        glfwPollEvents();
        glfwGetFramebufferSize(window, &fbWidth, &fbHeight);
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
        Resets the OpenGL viewport to fit the window
    */
    void resetViewport() {
        glViewport(0, 0, width, height);
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