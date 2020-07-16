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
import std.algorithm.mutation;

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
    bool canHint = true;
    SolTile[2] hints;

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

            // Find the valid pairs around
            auto validPairs = findValidPairs();
            auto validPair = validPairs[uniform(0, cast(int)validPairs.length)];

            // Change the type of the tiles to the next pair in the generator
            validPair[0].changeType(generator.getNext());
            validPair[1].changeType(generator.getNext());

            // Deactivate the tiles so we don't try setting them again
            validPair[0].deactivate();
            validPair[1].deactivate();

            pairsLeft--;
        }

        // Re-activate all the tiles.
        foreach(tile; tiles) tile.activate();
    }

    void generateBoard(FieldData formation) {
        this.name = formation.name;
        foreach(slot; formation.slots) {
            SolTile newTile = new SolTile(this, TileType.Unmarked);
            newTile.position = slot;
            tiles ~= newTile;
        }
        fillBoard();
    }
    
    SolTile[2][] findValidPairs() {
        SolTile[2][] validPairs;
        foreach(i; 0..tiles.length) {
            
            // Skip incative tiles
            if (!tiles[i].active) continue;

            foreach_reverse(j; 0..tiles.length) {

                // Skip incative tiles
                if (!tiles[j].active) continue;

                // A tile and itself is a bad hint
                if (tiles[i] == tiles[j]) continue;

                // Skip tiles we've already hinted
                if (tiles[i].hinted || tiles[j].hinted) continue;

                // Skip tiles the player can't play
                if (!tiles[i].isAvailable || !tiles[j].isAvailable) continue;

                // If they match then we mark them as hints and return
                if (tiles[i].type == tiles[j].type) {
                    validPairs ~= [tiles[i], tiles[j]];
                }

            }
        }
        return validPairs;
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

        import game.boards.solitaire.parser : parse;
        this.generateBoard(parse(import("fields/turtle.field")));
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
        Get a hint
    */
    void hint() {
        if (!canHint) return;
        canHint = false;

        auto validPairs = findValidPairs();

        // We've hit a dead end
        if (validPairs.length == 0) {
            canHint = true;
            return;
        }

        // Find a random pair and hint those
        size_t idx = uniform(0, validPairs.length);
        validPairs[idx][0].hint();
        validPairs[idx][1].hint();
        hints = [validPairs[idx][0], validPairs[idx][1]];
        board.score -= 100;
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
            current.deactivate();
            previous.deactivate();
            board.score += current.scoreWorth;
            this.resetSelection();
            canHint = true;
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

        // Deactivate any hints there were before
        if (hints[0] !is null) {
            hints[0].unhint();
            hints[0] = null;

            hints[1].unhint();
            hints[1] = null;
        }

        // Allow hinting again
        canHint = true;

        // Undo the last action
        SolAction action = actions.pop();
        action.paired[0].activate();
        action.paired[1].activate();

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