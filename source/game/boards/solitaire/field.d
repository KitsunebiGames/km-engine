/*
    Copyright © 2020, Luna Nielsen
    Distributed under the 2-Clause BSD License, see LICENSE file.
    
    Authors: Luna Nielsen
*/
module game.boards.solitaire.field;
import game.boards.solitaire;
import engine;
import game;
import game.tiles;
import std.random;

/**
    Data used to initialize a field
*/
struct FieldData {
public:

    /**
        Name of the field
    */
    string name;

    /**
        Slots in the field
    */
    vec3i[] slots;
}

/**
    Actions performed
*/
struct SolAction {

    /**
        The tiles paired
    */
    SolTile[2] paired;
}

/**
    The playing field
*/
class Field {
private:
    SolitaireBoard board;

    // Actions
    ActionStack!SolAction actions;
    int undos;

    SolTile current;
    SolTile previous;

    void resetSelection() {
        if (current !is null) {
            current.selected = false;
            current = null;
        }

        if (previous !is null) {
            previous.selected = false;
            previous = null;
        }
    }

    void fillBoard() {
        TileGenerator generator = new TileGenerator();

        int pairsLeft = cast(int)tiles.length/2;
        while (pairsLeft > 0) {
            int idx = uniform(0, cast(int)tiles.length);
            int idx2 = uniform(0, cast(int)tiles.length);

            // Skip tiles that are the same
            if (idx == idx2) continue;

            // Skip inactive tiles
            if (!tiles[idx].active || !tiles[idx2].active) continue;

            // We'll have to try again we didn't find a free pair
            if (tiles[idx].isAvailable && tiles[idx2].isAvailable) {

                // Deactivate the tiles so we don't try setting them again
                tiles[idx].active = false;
                tiles[idx2].active = false;

                // Change the type of the tiles to the next pair in the generator
                tiles[idx].changeType(generator.getNext());
                tiles[idx2].changeType(generator.getNext());

                // We've just matched 2 tiles, reflect that in how many there's left to "solve"
                pairsLeft--;
            }
        }

        // Re-activate all the tiles.
        foreach(tile; tiles) tile.active = true;
    }

    void generateBoard() {
        foreach(i; 0..144) {
            SolTile newTile = new SolTile(this, TileType.Unmarked);
            newTile.position = vec3i((i%18)*2, (i/18)*2, 0);
            tiles ~= newTile;
        }
        fillBoard();
    }

public:

    /**
        Name of the field
    */
    string name;

    /**
        The tiles on the field
    */
    SolTile[] tiles;

    this(SolitaireBoard board) {
        this.board = board;
        actions = new ActionStack!SolAction();
        this.generateBoard();
    }

    /**
        Update the tiles
    */
    void update() {
        foreach(tile; tiles) {
            tile.update();
        }
    }

    /**
        Draw the tiles
    */
    void draw(Camera camera) {
        Tile.begin();

        SolTile hovered = getTileHover(camera, Mouse.position, vec2(GameWindow.width, GameWindow.height));
        if (hovered !is null) {
            if (hovered.isAvailable) {
                hovered.hover();
            }
        }

        foreach(tile; tiles) {
            tile.draw(camera);
        }
        Tile.end();
    }

    /**
        Gets if the field is empty (the player has won)
    */
    bool empty() {
        int active = 0;
        foreach(tile; tiles) {
            if (tile.active) active++;
        }
        return active == 0;
    }

    /**
        Get the tile hovered over
    */
    SolTile getTileHover(Camera camera, vec2 mouse, vec2 viewport) {
        SolTile closest;
        float lastDistance = float.max;
        foreach(tile; tiles) {

            // Inactive tiles are to be ignored
            if (!tile.active) continue;

            float distance;
            if (tile.hovered(camera, mouse, viewport, distance)) {

                // Tile is closer to camera
                if (distance < lastDistance) {
                    lastDistance = distance;
                    closest = tile;
                }
            }
        }
        return closest;
    }
    
    /**
        Select a tile for pairing
    */
    bool pair(SolTile tile) {

        // Can't pair unavailable tiles
        if (!tile.isAvailable) return false;

        // Reset the selection if a tile is paired with itself
        if (current == tile) {
            this.resetSelection();
            return false;
        }

        // Update the state
        previous = current;
        current = tile;
        current.selected = true;

        // We can't pair anything (yet)
        if (previous is null) return false;

        // If tiles match then 
        if (previous.type == current.type) {
            actions.push(SolAction([current, previous]));
            current.active = false;
            previous.active = false;
            board.score += current.scoreWorth;
            this.resetSelection();
            return true;
        }

        // Tiles did not match, reset selection
        this.resetSelection();
        return false;
    }

    /**
        Undo an action
    */
    void undo() {
        
        // If we can't undo an action, return
        if (!actions.canPop()) return;

        // Undo the last action
        SolAction action = actions.pop();
        action.paired[0].active = true;
        action.paired[1].active = true;

        // Penalize the player
        board.score -= 50;
        undos++;
    }

    /**
        Calculate the bounds of the field
    */
    AABB calculateBounds() {
        vec3i start = vec3i(int.max);
        vec3i end = vec3i(0);
        foreach(tile; tiles) {
            // Skip tiles we can't see
            if (!tile.active) continue;

            if (tile.position.x < start.x) start.x = tile.position.x;
            if (tile.position.y < start.y) start.y = tile.position.y;
            if (tile.position.z < start.z) start.z = tile.position.z;

            if (tile.position.x > end.x) end.x = tile.position.x;
            if (tile.position.y > end.y) end.y = tile.position.y;
            if (tile.position.z > end.z) end.z = tile.position.z;
        }

        return AABB(
            vec3(start.x*(MahjongTileWidth/2), start.y*(MahjongTileHeight/2), start.z*MahjongTileLength), 
            vec3(end.x*(MahjongTileWidth/2), end.y*(MahjongTileHeight/2), end.z*MahjongTileLength)
        );
    }
}