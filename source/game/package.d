/*
    Copyright © 2020, Luna Nielsen
    Distributed under the 2-Clause BSD License, see LICENSE file.
    
    Authors: Luna Nielsen
*/
module game;
import engine;

/**
    Initializes the game
*/
void initGame() {
    GameWindow.title = "Kitsune Mahjong";
    glEnable(GL_BLEND);
    glEnable(GL_CULL_FACE);
}

/**
    The game loop
*/
void gameLoop() {
    while(!GameWindow.isExitRequested) {
        
        // Clear color and depth buffers
        glClear(GL_COLOR_BUFFER_BIT);
        glClear(GL_DEPTH_BUFFER_BIT);

        // Update and render the game


        // Swap buffers and poll stuff
        GameWindow.swapBuffers();
        GameWindow.pollEvents();
    }
}