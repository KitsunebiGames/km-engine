/*
    Copyright © 2020, Luna Nielsen
    Distributed under the 2-Clause BSD License, see LICENSE file.
    
    Authors: Luna Nielsen
*/
module game;
import engine;
import game.gamestate;
import bindbc.glfw;

private double previousTime_;
private double currentTime_;
private double deltaTime_;

/**
    Initializes the game
*/
void initGame() {
    // OpenGL prep stuff
    glEnable(GL_BLEND);
    glEnable(GL_CULL_FACE);

    // Set window title to something better
    GameWindow.title = "Kitsune Mahjong";
    GameWindow.setSwapInterval(SwapInterval.Unlimited);

    // Push the main menu to the stack
    GameStateManager.push(new IntroState());
}

/**
    The game loop
*/
void gameLoop() {
    resetTime();
    while(!GameWindow.isExitRequested) {

        currentTime_ = glfwGetTime();
        deltaTime_ = currentTime_-previousTime_;
        previousTime_ = currentTime_;
        
        // Clear color and depth buffers
        glClear(GL_COLOR_BUFFER_BIT);
        glClear(GL_DEPTH_BUFFER_BIT);

        // Update and render the game
        GameStateManager.update();
        GameStateManager.draw();

        // Swap buffers and poll stuff
        GameWindow.swapBuffers();
        GameWindow.pollEvents();

    }
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