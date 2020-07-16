/*
    Copyright © 2020, Luna Nielsen
    Distributed under the 2-Clause BSD License, see LICENSE file.
    
    Authors: Luna Nielsen
*/
module game.boards;
public import game.boards.solitaire;
public import game.gamestate.ingame;
import engine;
import game;

/**
    A board contains all the logic and rendering code used for a game/board
*/
abstract class GameBoard {
private:
    double startTime;

protected:
    InGameState parent;

public:

    /**
        The score
    */
    int score;

    /**
        Create new game board
    */
    this(InGameState parent) {
        this.parent = parent;
        startTime = currTime;
    }

    /**
        How long you've been playing the board in seconds
    */
    final double time() {
        return currTime-startTime;
    }

    /**
        Update the game board
    */
    abstract void update();

    /**
        Draw the game board
    */
    abstract void draw();
}

/**
    Board Camera, a simple camera for most game boards
*/
class BoardCam {
private:
    Transform cameraBase;
    Transform cameraPivot;
    Transform cameraArm;
    vec3 target;
    vec3 rotation;

public:
    /**
        Construct board camera
    */
    this() {

        rotation = vec3(0);

        // Set up camera
        cameraBase = new Transform();
        cameraPivot = new Transform(cameraBase);
        cameraArm = new Transform(cameraPivot);
        camera = new Camera(cameraArm);

        // TODO: make these customizable
        cameraArm.position.z = -8;
        camera.fov = 30;
    }

    /**
        The underlying 3D camera
    */
    Camera camera;

    /**
        Set the point the camera focuses at
    */
    void setFocus(vec3 area, bool instant = false) {
        target = -area;
        if (instant) {
            cameraBase.position = target;
        }
    }

    /**
        Updates the camer's transforms
    */
    void update() {
        vec2 winCenter = vec2(GameWindow.width/2, GameWindow.height/2);
        vec2 mousePos = Mouse.position;

        mousePos.x = clamp(mousePos.x, 0, GameWindow.width);
        mousePos.y = clamp(mousePos.y, 0, GameWindow.height);

        float mouseRelX = (mousePos.x-winCenter.x)/GameWindow.width;
        float mouseRelY = (mousePos.y-winCenter.y)/GameWindow.height;

        rotation = rotation.dampen(vec3(-(mouseRelY*0.8), -(mouseRelX*0.8), 0), deltaTime, 4);
        cameraPivot.rotation = quat.euler_rotation(rotation.x, rotation.y, rotation.z);

        // Smoothly move the camera to the target
        cameraBase.position = cameraBase.position.dampen(target, deltaTime);
    }

}