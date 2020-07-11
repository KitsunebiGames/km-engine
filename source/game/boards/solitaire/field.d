/*
    Copyright © 2020, Luna Nielsen
    Distributed under the 2-Clause BSD License, see LICENSE file.
    
    Authors: Luna Nielsen
*/
module game.boards.solitaire.field;
import engine;
import game;
import game.boards.solitaire.tilegen;
import std.random;

private struct TileVec {
    int x;
    int y;
}

/**
    The playing field
*/
class Field {
private:
    Tile[TileVec] tiles;

    void placeInFreeSpot(Tile tile, int width, int height) {
        TileVec position;
        do {
            position = TileVec(uniform(0, width), uniform(0, height));
        } while(position in tiles);

        // Set the tile in an appropriate position
        tile.transform.position = vec3(
            MahjongTileWidth*(cast(float)position.x-(width/2)),
            MahjongTileHeight*(cast(float)position.y-(height/2)),
            0
        );

        // Put the tile in to the field
        tiles[position] = tile;
    }

public:

    this() {
        TileGenerator generator = new TileGenerator();

        foreach(i; 0..144) {
            placeInFreeSpot(generator.getNext(), 18, 8);
        }
    }

    void draw(Camera camera) {
        Tile.begin();

        foreach(tile; tiles) {
            tile.draw(camera);
        }

        Tile.end();
    }

    /**
        Gets if the field is empty (the player has won)
    */
    bool empty() {
        return tiles.length == 0;
    }
}