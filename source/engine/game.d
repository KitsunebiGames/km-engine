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
    Function run when the game is to update
*/
void function() gameUpdate;

/**
    Function run when the game is to initialize
*/
void function() gameInit;

/**
    Function run when the game is to clean up
*/
void function() gameCleanup;

/**
    Starts the game loop
*/
void startGame() {
    gameInit();
    resetTime();
    while(!GameWindow.isExitRequested) {

        currentTime_ = glfwGetTime();
        deltaTime_ = currentTime_-previousTime_;
        previousTime_ = currentTime_;
        
        // Clear color and depth buffers
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

        // Reset OpenGL viewport
        GameWindow.resetViewport();

        // Update and render the game
        gameUpdate();

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