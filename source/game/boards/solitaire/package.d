/*
    Copyright © 2020, Luna Nielsen
    Distributed under the 2-Clause BSD License, see LICENSE file.
    
    Authors: Luna Nielsen
*/
module game.boards.solitaire;
public import game.boards.solitaire.field;
public import game.boards.solitaire.tile;
public import game.boards.solitaire.tilegen;
import game.boards;
import game.tiles;
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

    /**
        Constructor
    */
    this(InGameState ingame) {
        super(ingame);

        // Initialize mahjong tiles
        initMahjong("default");

        playingField = new Field(this);
        ui = new Camera2D();
        camera = new BoardCam();
        camera.setFocus(playingField.calculateBounds.center, true);
    }

override:

    void update() {
        camera.update();
        playingField.update();

        if (Mouse.isButtonClicked(MouseButton.Left)) {

            // Do tile pairing
            SolTile tile = playingField.getTileHover(camera.camera, Mouse.position, vec2(GameWindow.width, GameWindow.height));
            if (tile !is null) {
                if (playingField.pair(tile)) {
                    parent.june.tileCleared();
                }
            }

            if (playingField.empty) {
                GameStateManager.push(new GameOverState(this.score, this.time));
            }

            // Set the focus to the new bounds center (if the play area shrinks)
            camera.setFocus(playingField.calculateBounds().center);
        }

        if (Mouse.isButtonClicked(MouseButton.Right)) {
            playingField.undo();
            camera.setFocus(playingField.calculateBounds().center);
        }

        if (Mouse.isButtonClicked(MouseButton.Middle)) {
            playingField.hint();
            camera.setFocus(playingField.calculateBounds().center);
        }
    }

    void draw() {
        playingField.draw(camera.camera);
    }
}