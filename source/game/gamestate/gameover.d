/*
    Copyright © 2020, Luna Nielsen
    Distributed under the 2-Clause BSD License, see LICENSE file.
    
    Authors: Luna Nielsen
*/
module game.gamestate.gameover;
import game.gamestate;
import engine;
import game;
import gl3n.linalg;
import gl3n.math;
import gl3n.interpolate;
import std.format;


/**
    Game Over State
*/
class GameOverState : GameState {
private:
    int score;
    double time;

public:
    /**
        No passthrough
    */
    this(int score, double time) {
        this.drawPassthrough = false;
        this.score = score;
        this.time = time;
        AppLog.info("debug", "Player Won! score=%s time=%ss", score, time);
    }

override:

    void update() {
        if (Mouse.isButtonClicked(MouseButton.Left)) {
            GameStateManager.pop();
            GameStateManager.pop();
        }
    }

    void draw() {


    }
}