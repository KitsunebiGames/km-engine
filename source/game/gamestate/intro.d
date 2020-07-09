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
import std.format;


/**
    Main menu state
*/
class IntroState : GameState {
private:
    Camera testCamera;
    Tile[] tiles;
    Transform cameraRoot;
    float rtest = 0;

public:
    /**
        No passthrough
    */
    this() {
        this.drawPassthrough = false;
        cameraRoot = new Transform();
        testCamera = new Camera(new Transform(vec3(0, 0, -4), cameraRoot));
        
        enum sz = 100;

        foreach(y; 0..sz) {
            foreach(x; 0..sz) {
                auto tile = new Tile(TileType.Dot1);
                
                float xp = cast(float)(x-(sz/2))/3.5;
                float yp = cast(float)(y-(sz/2))/2.5;

                tile.transform.position = vec3(xp, yp, 0);
                tiles ~= tile;
            }
        }
    }

override:
    void update() {
        rtest += deltaTime+0.001;
        //cameraRoot.rotation = quat.euler_rotation(sin(rtest*2)/2, rtest, cos(rtest*2)/2);
    }

    void draw() {

        // Apply shader only once
        Tile.beginShading();
        foreach(i, tile; tiles) {
            float scaleVal = sin(rtest+i)/2;
            tile.transform.scale = vec3(1+scaleVal, 1+scaleVal, 1+scaleVal);
            tile.draw(testCamera);
        }
        GameWindow.title = "%sms drawing %s tiles".format(cast(int)(deltaTime*1000), tiles.length);
    }

    void onActivate() {

        // Set window title
        GameWindow.title = "Welcome to Kitsune Mahjong";
    }
}