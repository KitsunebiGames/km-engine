/*
    Copyright © 2020, Luna Nielsen
    Distributed under the 2-Clause BSD License, see LICENSE file.
    
    Authors: Luna Nielsen
*/
module game.gamestate.ingame;
public import game.june;
import game.gamestate;
import game.boards;
import engine;
import game;

/**
    The game state of ingame
*/
class InGameState : GameState {
private:
    GameBoard board;
    string targetGame;
    Texture background;


    void drawBackground() {
        vec2 winSize = vec2(GameWindow.width, GameWindow.height);
        vec2 winCenter = vec2(winSize.x/2, winSize.y/2);
        vec2 texSize = vec2(background.width, background.height);
        vec2 size = vec2(0, 0);

        // Texture ratios
        vec2 texRatios = vec2(
            texSize.x/texSize.y, 
            texSize.y/texSize.x
        );

        // Window ratios
        vec2 winRatios = vec2(
            winSize.x/winSize.y, 
            winSize.y/winSize.x
        );

        float biggestWin = max(winSize.x, winSize.y);
        if (texSize.y <= texSize.x) {
            size = vec2(biggestWin*texRatios.y, biggestWin*texRatios.y);
        } else {
            size = vec2(biggestWin*texRatios.x, biggestWin*texRatios.x);
        }

        // Clamp for stuff smaller
        immutable(float) biggestWidth = max(texSize.x, winSize.x);
        immutable(float) biggestHeight = max(texSize.y, winSize.y);
        size.x = clamp(size.x, biggestWidth, int.max)+8;
        size.y = clamp(size.y, biggestHeight, int.max)+8;

        // Get the relative mouse position
        vec2 mousePos = Mouse.position;

        mousePos.x = clamp(mousePos.x, 0, GameWindow.width);
        mousePos.y = clamp(mousePos.y, 0, GameWindow.height);

        float mouseRelX = (mousePos.x-winCenter.x)/GameWindow.width;
        float mouseRelY = (mousePos.y-winCenter.y)/GameWindow.height;


        // Render background
        GameBatch.draw(background, vec4(winCenter.x+(mouseRelX*8), winCenter.y+(mouseRelY*8), size.x, size.y), vec4.init, vec2(size.x/2, size.y/2));
        GameBatch.flush();
    }

public:
    this(string targetGame) {
        this.targetGame = targetGame;

        // TODO: actually use targetGame

        this.board = new SolitaireBoard(this);
        background = new Texture("assets/textures/backgrounds/forest.jpg");

        june = new June();
    }

    /**
        It's june!
    */
    June june;

    override void update() {
        this.board.update();

        june.update();
    }

    override void draw() {

        // Draw background for game
        drawBackground();

        // Draw board
        this.board.draw();

        // Draw june
        june.draw(vec2(GameWindow.width-64, GameWindow.height));
    }

    override void onActivate() {
        GameWindow.title = "Kitsune Mahjong: "~targetGame;
    }
}