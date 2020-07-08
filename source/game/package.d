module game;
import engine;

/**
    Initializes the game
*/
void initGame() {
    GameWindow.title = "Kitsune Mahjong";
}

/**
    The game loop
*/
void gameLoop() {
    while(!GameWindow.isExitRequested) {
        // Update and render the game

        // Swap buffers and poll stuff
        GameWindow.swapBuffers();
        GameWindow.pollEvents();
    }
}