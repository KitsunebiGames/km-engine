/*
    Copyright © 2020, Luna Nielsen
    Distributed under the 2-Clause BSD License, see LICENSE file.
    
    Authors: Luna Nielsen
*/
module engine.game;
import bindbc.glfw;
import engine;

private double previousTime_;
private double currentTime_;
private double deltaTime_;

/**
    Function run when the game is to initialize
*/
void function() gameInit;

/**
    Function run when the game is to update
*/
void function() gameUpdate;

/**
    Function run after the main rendering has happened, Used to draw borders for the gameplay
*/
void function() gameBorder;

/**
    Function run after updates and rendering of the game
*/
void function() gamePostUpdate;

/**
    Function run when the game is to clean up
*/
void function() gameCleanup;

/**
    Starts the game loop

    viewportSize sets the desired viewport size for the framebuffer, defaults to 1080p (1920x1080)
*/
void startGame(vec2i viewportSize = vec2i(1920, 1080)) {
    gameInit();
    resetTime();

    Framebuffer framebuffer = new Framebuffer(GameWindow, viewportSize);
    while(!GameWindow.isExitRequested) {

        currentTime_ = glfwGetTime();
        deltaTime_ = currentTime_-previousTime_;
        previousTime_ = currentTime_;
        
        // Bind our framebuffer
        framebuffer.bind();

            // Clear color and depth buffers
            glClearColor(0, 0, 0, 1);
            glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

            // Update and render the game
            gameUpdate();

        // Unbind our framebuffer
        framebuffer.unbind();
    
        // Clear color and depth bits
        glClearColor(0, 0, 0, 0);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

        // Draw border, framebuffer and post update content
        if (gameBorder !is null) gameBorder();
        framebuffer.renderToFit();
        if (gamePostUpdate !is null) gamePostUpdate();

        // Update the mouse's state
        Mouse.update();

        // Swap buffers and update the window
        GameWindow.swapBuffers();
        GameWindow.update();
    }

    // Game cleanup
    gameCleanup();
}

/**
    Gets delta time
*/
double deltaTime() {
    return deltaTime_;
}

/**
    Gets delta time
*/
double prevTime() {
    return previousTime_;
}

/**
    Gets delta time
*/
double currTime() {
    return currentTime_;
}

/**
    Resets the time scale
*/
void resetTime() {
    glfwSetTime(0);
    previousTime_ = 0;
    currentTime_ = 0;
}