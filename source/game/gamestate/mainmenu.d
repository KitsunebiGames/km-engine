/*
    Copyright © 2020, Luna Nielsen
    Distributed under the 2-Clause BSD License, see LICENSE file.
    
    Authors: Luna Nielsen
*/
module game.gamestate.mainmenu;
import game.gamestate;
import engine;

/**
    Main menu state
*/
class MainMenuState : GameState {
public:
    /**
        No passthrough
    */
    this() {
        this.drawPassthrough = false;
    }

override:
    void update() {
        GameStateManager.push(new InGameState("Mahjong Solitaire"));
    }

    void draw() {

    }

    void onActivate() {
        GameWindow.title = "Kitsune Mahjong: Main Menu";
    }
}