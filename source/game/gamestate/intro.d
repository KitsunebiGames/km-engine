/*
    Copyright © 2020, Luna Nielsen
    Distributed under the 2-Clause BSD License, see LICENSE file.
    
    Authors: Luna Nielsen
*/
module game.gamestate.intro;
import game.gamestate;
import engine;
import game;
import std.format;

/**
    Main menu state
*/
class IntroState : GameState {
public:
    /**
        No passthrough
    */
    this() {
        this.drawPassthrough = false;
    }

override:
    void update() {
    }

    void draw() {

    }

    void onActivate() {
        GameWindow.title = "Welcome to Kitsune Mahjong";
    }
}