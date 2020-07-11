/*
    Copyright © 2020, Luna Nielsen
    Distributed under the 2-Clause BSD License, see LICENSE file.
    
    Authors: Luna Nielsen
*/
module game.gamestate.intro;
import game.gamestate;
import engine;
import game;
import gl3n.linalg;
import gl3n.math;
import gl3n.interpolate;
import std.format;


/**
    Main menu state
*/
class IntroState : GameState {
private:
    Texture splashTexture;
    float progress = 0;
    enum ProgressSpeed = 1;

    float alpha;

public:
    /**
        No passthrough
    */
    this() {
        this.drawPassthrough = false;

        // Set window title
        GameWindow.title = "Welcome to Kitsune Mahjong";

        splashTexture = new Texture("assets/textures/splash.png");
    }

override:

    void update() {
        alpha = interp_hermite(0, 0.5, 1, 0.5, progress <= 1 ? progress : 2-progress);
        progress += deltaTime*ProgressSpeed;

        if (progress >= 2) {
            GameStateManager.pop();
            GameStateManager.push(new MainMenuState());
        }
    }

    void draw() {

        int smallest = min(GameWindow.width, GameWindow.height);

        GameBatch.draw(splashTexture, 
            vec4(GameWindow.width/2, GameWindow.height/2, smallest, smallest), 
            vec4.init, 
            vec2(smallest/2, smallest/2),
            0f,
            vec4(1, 1, 1, alpha));
        GameBatch.flush();
    }

    void onActivate() {

        // TODO: remove this once there's a game
        GameStateManager.pop();
        GameStateManager.push(new MainMenuState());
    }

    void onDeactivate() {
        destroy(splashTexture);
    }
}