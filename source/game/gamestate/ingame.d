/*
    Copyright © 2020, Luna Nielsen
    Distributed under the 2-Clause BSD License, see LICENSE file.
    
    Authors: Luna Nielsen
*/
module game.gamestate.ingame;
import game.gamestate;
import game.boards;
import engine;
import game;

class InGameState : GameState {
private:
    GameBoard board;
    string targetGame;

    Texture june;
    vec2 juneScale;
    float time = 0;

public:
    this(string targetGame) {
        this.targetGame = targetGame;

        // TODO: actually use targetGame

        this.board = new SolitaireBoard();
        june = new Texture("assets/textures/june/junesmile.png");
        june.setFiltering(Filtering.Linear);
        juneScale = vec2(june.width/5, june.height/5);
    }

    override void update() {
        this.board.update();

        time += deltaTime*1;
    }

    override void draw() {
        this.board.draw();

        GameBatch.draw(june, vec4(GameWindow.width-(juneScale.x/4), (GameWindow.height+64)-(sin(time)*4), juneScale.x, juneScale.y), vec4.init, vec2(juneScale.x/2, juneScale.y));
        GameBatch.flush();
    }

    override void onActivate() {
        GameWindow.title = "Kitsune Mahjong: "~targetGame;
    }
}