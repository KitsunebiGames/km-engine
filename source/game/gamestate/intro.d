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
    Transform cameraGimbalX;
    float rtest = 0;

    vec2 startRot;
    vec2 rot;
    vec2 dragStart;
    bool dragging;

    AtlasIndex cachedJune;

public:
    /**
        No passthrough
    */
    this() {
        this.drawPassthrough = false;
        cameraRoot = new Transform();
        cameraGimbalX = new Transform(cameraRoot);
        testCamera = new Camera(new Transform(vec3(0, 0, -2), cameraGimbalX));
        rot = vec2(0, 0);

        
        // enum sz = 100;
        // foreach(y; 0..sz) {
        //     foreach(x; 0..sz) {
        //         auto tile = new Tile(TileType.Dot1);
                
        //         float xp = (MahjongTileWidth+0.1)*cast(float)(x-(sz/2));
        //         float yp = (MahjongTileHeight+0.1)*cast(float)(y-(sz/2));

        //         tile.transform.position = vec3(xp, yp, 0);
        //         tiles ~= tile;
        //     }
        // }

        enum sz = cast(int)TileType.ExtendedSetTileCount;
        foreach(i; 0..sz) {
            auto tile = new Tile(cast(TileType)i);
            float xp = (MahjongTileWidth+0.1)*cast(float)(i%10);
            float xy = (MahjongTileWidth+0.1)*cast(float)(i/10);
            tile.transform.position = vec3(xp, -xy, 0);

            tiles ~= tile;
        }
    }

override:
    void update() {
        rtest += deltaTime+0.001;

        if (Mouse.isButtonPressed(MouseButton.Middle)) {
            if (!dragging) {
                dragging = true;
                dragStart = Mouse.position;
                startRot = rot;
            }

            vec2 dragOffset = dragStart-Mouse.position;
            rot.x = startRot.x-dragOffset.x/GameWindow.width;
            rot.y = startRot.y+dragOffset.y/GameWindow.height;

            cameraRoot.rotation = quat.zrotation(rot.x);
            cameraGimbalX.rotation = quat.xrotation(rot.y);
        }

        if (Keyboard.isKeyPressed(Key.KeyA)) {
            cameraRoot.position.x += deltaTime*1;
        }
        if (Keyboard.isKeyPressed(Key.KeyD)) {
            cameraRoot.position.x -= deltaTime*1;
        }
        if (Keyboard.isKeyPressed(Key.KeyW)) {
            cameraRoot.position.y -= deltaTime*1;
        }
        if (Keyboard.isKeyPressed(Key.KeyS)) {
            cameraRoot.position.y += deltaTime*1;
        }

        if (Mouse.isButtonReleased(MouseButton.Middle)) {
            dragging = false;
        }
    }

    void draw() {

        // Begin drawing tiles
        Tile.begin();
        foreach(i, tile; tiles) {
            tile.draw(testCamera);
        }
        GameWindow.title = "%sms drawing %s tiles".format(cast(int)(deltaTime*1000), tiles.length);
    }

    void onActivate() {

        // Set window title
        GameWindow.title = "Welcome to Kitsune Mahjong";
    }
}