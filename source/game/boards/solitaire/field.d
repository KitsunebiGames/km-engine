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

        // Update the collider so we can click it
        tile.updateCollider();

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

    /**
        Index the tiles
    */
    Tile opIndex(vec2i index) {
        return TileVec(index.x, index.y) in tiles ? tiles[TileVec(index.x, index.y)] : null;
    }

    /**
        Gets the tile the player clicked
    */
    vec2i getClicked(Camera camera, vec2 mouse, vec2 viewport) {
        Ray castRay = mouse.castScreenSpaceRay(viewport, camera.matrix);
        TileVec closest = TileVec(int.min, int.min);
        float lastDistance = float.max;
        foreach(pos, tile; tiles) {

            // Check ray intersections on the tile
            float distance;
            if (tile.collider.isRayIntersecting(castRay, tile.transform.matrix, distance)) {
                AppLog.info("debug", "Intersection...");
                
                // This tile was closer to the camera, select that.
                if (distance < lastDistance) {
                    lastDistance = distance;
                    closest = pos;
                }
            }
        }

        return vec2i(closest.x, closest.y);
    }

    /**
        Remove tile from board
    */
    void remove(vec2i index) {
        destroy(tiles[TileVec(index.x, index.y)]);
        tiles.remove(TileVec(index.x, index.y));
    }

    /**
        Gets if the index specified is playable
    */
    bool isPlayable(vec2i index) {
        return TileVec(index.x-1, index.y) !in tiles || TileVec(index.x+1, index.y) !in tiles; 
    }

    /**
        Shuffle the board
    */
    void shuffle(int width = 18, int height = 8) {
        import std.algorithm.mutation : remove;
        TileVec[] positions;
        Tile[] tiles;

        // Populate our arrays
        foreach(pos, tile; this.tiles) {
            positions ~= pos;
            tiles ~= tile;
        }

        // Clear them out
        this.tiles.clear();

        // Rearrange
        foreach(i, tile; tiles) {
            size_t posIndex = uniform(0, positions.length);
            TileVec pos = positions[posIndex];

            // Set the tile in an appropriate position
            tile.transform.position = vec3(
                MahjongTileWidth*(cast(float)pos.x-(width/2)),
                MahjongTileHeight*(cast(float)pos.y-(height/2)),
                0
            );

            // Update the collider so we can click it
            tile.updateCollider();

            // Put the tile in to the field
            this.tiles[pos] = tile;

            // Remove one possible position from the list
            positions = positions.remove(posIndex);
        }
    }
}