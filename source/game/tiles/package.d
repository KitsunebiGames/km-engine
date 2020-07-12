/*
    Copyright © 2020, Luna Nielsen
    Distributed under the 2-Clause BSD License, see LICENSE file.
    
    Authors: Luna Nielsen
*/
module game.tiles;
public import game.tiles.mahjong;
import engine;
import game;

/**
    A tile
*/
abstract class Tile {
public:

    /**
        Set the transform
    */
    this() {
        transform = new Transform();
        this.update();
    }

    /**
        The transform of the tile
    */
    Transform transform;

    /**
        The tile's collider
    */
    OBB collider;

    /**
        Begin rendering
    */
    static void begin() {
        TileMesh.begin();
    }

    /**
        Begin rendering
    */
    static void end() {
        TileMesh.begin();
    }

    /**
        Draw the tile
    */
    abstract void draw(Camera camera);

    /**
        Draw the tile in a 2D plane
    */
    abstract void draw2d(Camera2D camera, vec2 position, float scale = 1, quat rotation = quat.identity);

    /**
        Update the tile
    */
    abstract void update();
}