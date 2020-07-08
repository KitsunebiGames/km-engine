/*
    Copyright © 2020, Luna Nielsen
    Distributed under the 2-Clause BSD License, see LICENSE file.
    
    Authors: Luna Nielsen
*/
module game.gamestate;
public import game.gamestate.mainmenu;
public import game.gamestate.intro;

/**
    Manager of game states
*/
class GameStateManager {
private static:
    GameState[] states;

public static:

    /**
        Update the current game state
    */
    void update() {
        if (states.length == 0) return;
        states[$-1].update();
    }

    /**
        Draw the current game state

        Offset sets the offset from the top of the stack to draw
    */
    void draw(size_t offset = 1) {
        if (states.length == 0) return;

        // Handle drawing passthrough, this allows us to draw game boards with game over screen overlayed.
        if (states[$-offset].drawPassthrough && states.length > offset) {
            states[$-offset].draw();
        }

        // Draw the current state
        states[$-offset].draw();
    }

    /**
        Push a game state on to the stack
    */
    void push(GameState state) {
        states ~= state;
        states[$-1].onActivate();
    }

    /**
        Pop a game state from the stack
    */
    void pop() {
        if (states.length > 0) {    
            states[$-1].onDeactivate();
            states.length--;
        }
    }

}

/**
    A game state
*/
abstract class GameState {
public:
    /**
        Wether drawing should pass-through to the previous game state (if any)
        This allows overlaying a gamr state over an other
    */
    bool drawPassthrough;

    /**
        Update the game state
    */
    abstract void update();

    /**
        Draw the game state
    */
    abstract void draw();

    /**
        When a state is pushed
    */
    void onActivate() { }

    /**
        Called when a state is popped
    */
    void onDeactivate() { }
}