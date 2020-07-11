/*
    Copyright © 2020, Luna Nielsen
    Distributed under the 2-Clause BSD License, see LICENSE file.
    
    Authors: Luna Nielsen
*/
module game.boards;
public import game.boards.solitaire;

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