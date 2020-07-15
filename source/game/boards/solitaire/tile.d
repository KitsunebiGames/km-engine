/*
    Copyright © 2020, Luna Nielsen
    Distributed under the 2-Clause BSD License, see LICENSE file.
    
    Authors: Luna Nielsen
*/
module game.boards.solitaire.tile;
import game.boards.solitaire;
import engine;
import game;
import game.tiles;
import game.tiles.mahjong;

/**
    A solitaire tile
*/
class SolTile : MahjongTile {
private:
    Field parent;
    bool isHovering;

public:

    /**
        Position of the tile

        X and Y position steps represent half a tile's worth of position
        Z represents an entire tile depth's worth of position
    */
    vec3i position;

    /**
        Whether the piece is active
    */
    bool active = true;

    /**
        Whether the tile is currently selected
    */
    bool selected;

    /**
        Constructor
    */
    this(Field parent, TileType type) {
        this.parent = parent;
        super(type);
        transform.scale = vec3(0);
    }

    /**
        Gets whether the mouse is hovering over the tile
    */
    bool hovered(Camera camera, vec2 mouse, vec2 viewport, ref float distance) {

        // Can't hover over an inactive tile
        if (!active) return false;

        // Cast a ray and find out if the tile is hovered over
        Ray castRay = mouse.castScreenSpaceRay(viewport, camera.matrix);
        return collider.isRayIntersecting(castRay, transform.matrixUnscaled, distance);
    }

    /**
        Mark has hovering
    */
    void hover() {
        isHovering = true;
    }

    /**
        Gets whether the tile is available to be moved
    */
    bool isAvailable() {

        // Inactive tiles aren't available
        if (!this.active) return false;

        bool isBlockedOnLeft;
        bool isBlockedOnRight;
        foreach(SolTile other; parent.tiles) {

            // Skip self and inactive tiles
            if (other == this || !other.active) continue;

            // Tiles above which are overlaying this tile make the tile unavailable
            // This includes half step positions on the X and Y axis
            if (other.position.z == position.z + 1 &&
                (other.position.x >= position.x-1 && other.position.x <= position.x+1) && 
                (other.position.y >= position.y-1 && other.position.y <= position.y+1))
                return false;

            // Tiles blocked on the right and left are unavailable
            // The extra Y check allows checking tiles stacked on half step Y to be detected
            // Relevant for formations like The Turtle
            if (other.position.z == position.z && (other.position.y >= position.y-1 && other.position.y <= position.y+1)) {

                // Update blocked state based on if the tile is to the right or left of this tile
                if (other.position.x == position.x-2) isBlockedOnLeft = true;
                if (other.position.x == position.x+2) isBlockedOnRight = true;
                
                // If tile is both blocked on right and left then it's unavailable
                if (isBlockedOnLeft && isBlockedOnRight) return false;
            }
        }

        return true;
    }

    /**
        Gets how much score the tile is worth
    */
    int scoreWorth() {
        return 100;
    }

    /**
        Draws the tile
    */
    override void draw(Camera camera) {
        if (active || transform.scale.y > 0) mesh.draw(camera, transform.matrix);
    }

    /**
        Update the tile
    */
    override void update() {
        super.update();

        // Make the tile dissapear if it's deactivated
        if (!active) {
            vec3 targetScale = vec3(0);
            transform.scale = transform.scale.dampen(targetScale, deltaTime, 2);
            return;
        }

        // Each position step on X and Y represents half a mahjong tile's worth of position
        // A step in the Z axis represents a full mahjong height
        vec3 target = vec3(position.x*(MahjongTileWidth/2), position.y*(MahjongTileHeight/2), position.z*MahjongTileLength);
        vec3 targetScale = vec3(1);
        float scaleSpeed = isHovering ? 2 : 1;

        // If it's just selected set the scale smaller
        if (selected) targetScale = vec3(0.9);

        // If we're hovering over it but it's not selected scale it up and shift it forward
        if (isHovering && !selected) {
            targetScale = vec3(1.1);
            target.z += 0.2;
        }

        // Scale up a tiny bit if it's selected and we're hovering over it
        if (isHovering && selected) targetScale = vec3(0.95);
        

        // Smoothly dampen between values
        transform.position = transform.position.dampen(target, deltaTime);
        transform.scale = transform.scale.dampen(targetScale, deltaTime, scaleSpeed);

        // Reset hovering state
        isHovering = false;
    }
}