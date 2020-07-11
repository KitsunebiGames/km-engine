/*
    Copyright © 2020, Luna Nielsen
    Distributed under the 2-Clause BSD License, see LICENSE file.
    
    Authors: Luna Nielsen
*/
module game.boards;
public import game.boards.solitaire;
import engine;

/**
    A board contains all the logic and rendering code used for a game/board
*/
abstract class GameBoard {
public:

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
    Transform cameraPivot;
    Transform cameraArm;

public:
    /**
        Construct board camera
    */
    this() {

        // Set up camera
        cameraPivot = new Transform();
        cameraArm = new Transform(cameraPivot);
        cameraPivot.position.z = -(MahjongTileLength*2);
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
        Updates the camer's transforms
    */
    void update() {
        vec2 winCenter = vec2(GameWindow.width/2, GameWindow.height/2);
        vec2 mousePos = Mouse.position;

        mousePos.x = clamp(mousePos.x, 0, GameWindow.width);
        mousePos.y = clamp(mousePos.y, 0, GameWindow.height);

        float mouseRelX = (mousePos.x-winCenter.x)/GameWindow.width;
        float mouseRelY = (mousePos.y-winCenter.y)/GameWindow.height;

        cameraPivot.rotation = quat.euler_rotation(-(mouseRelY*0.5), -(mouseRelX*0.5), 0);
    }

}