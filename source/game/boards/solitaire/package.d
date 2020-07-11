/*
    Copyright © 2020, Luna Nielsen
    Distributed under the 2-Clause BSD License, see LICENSE file.
    
    Authors: Luna Nielsen
*/
module game.boards.solitaire;
import game.boards.solitaire.field;
import game.boards;
import engine;
import game;
import std.random;



/**
    Solitaire Board
*/
class SolitaireBoard : GameBoard {
private:
    Field playingField;

    BoardCam camera;
    Camera2D ui;

public:
    this() {
        playingField = new Field();

        ui = new Camera2D();
        camera = new BoardCam();
    }

override:

    void update() {
        camera.update();
    }

    void draw() {
        playingField.draw(camera.camera);
    }
}