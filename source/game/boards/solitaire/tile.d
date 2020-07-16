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
    bool isHinted;
    bool isActive = true;
    bool isAnimating;
    float animTime = 0;

public:

    /**
        Position of the tile

        X and Y position steps represent half a tile's worth of position
        Z represents an entire tile depth's worth of position
    */
    vec3i position;

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
        if (!isActive) return false;

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
        Mark the tile as a hinted tile
    */
    void hint() {
        isHinted = true;
    }

    /**
        Mark the tile as a non-hinted tile
    */
    void unhint() {
        isHinted = false;
    }

    /**
        Gets whether the tile is hinted
    */
    bool hinted() {
        return isHinted;
    }

    /**
        Deactivate the tile
    */
    void deactivate() {
        this.isActive = false;
        this.isHinted = false;
        isAnimating = true;
        animTime = 1;
    }

    /**
        Deactivate the tile
    */
    void activate() {
        this.isActive = true;
        this.isHinted = false;
        isAnimating = false;
    }

    /**
        Gets whether this is active
    */
    bool active() {
        return isActive;
    }

    /**
        Gets whether the tile is available to be moved
    */
    bool isAvailable() {

        // Inactive tiles aren't available
        if (!this.isActive) return false;

        bool isBlockedOnLeft;
        bool isBlockedOnRight;
        foreach(SolTile other; parent.tiles) {

            // Skip self and inactive tiles
            if (other == this || !other.isActive) continue;

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
        if (isActive || isAnimating) mesh.draw(camera, transform.matrix);
    }

    /**
        Update the tile
    */
    override void update() {
        super.update();

        // Unneeded time spent doing this
        if (!isActive && !isAnimating) return;

        // Each position step on X and Y represents half a mahjong tile's worth of position
        // A step in the Z axis represents a full mahjong height
        vec3 target = vec3(position.x*(MahjongTileWidth/2), position.y*(MahjongTileHeight/2), position.z*MahjongTileLength);
        vec3 targetScale = vec3(1);
        vec3 targetRotation = vec3(0);
        vec3 curRotation = vec3(transform.rotation.roll, transform.rotation.pitch, transform.rotation.yaw);
        float scaleSpeed = isHovering ? 2 : 1;

        // Make the tile dissapear if it's deactivated
        if (!isActive && isAnimating) {

            // Roughly half a sec for animation to finish
            animTime -= deltaTime * 4;

            targetRotation = vec3(1, 0, 0);
            target.z += MahjongTileLength*2;
            targetScale = vec3(0);

            // Animation is done
            if (animTime <= 0) {
                isAnimating = false;
                transform.scale = vec3(1);
            }
        } else {
            // If it's just selected set the scale smaller
            if (selected) targetScale = vec3(0.9);

            // If we're hovering over it but it's not selected scale it up and shift it forward
            if (isHovering && !selected) {
                targetScale = vec3(1.1);
                target.z += 0.2;
            }

            // Scale up a tiny bit if it's selected and we're hovering over it
            if (isHovering && selected) targetScale = vec3(0.95);
            
            // Make the tile wiggle
            if (isHinted && !selected) {
                targetRotation.y = sin(currTime*20)*0.2;
                target.z += 0.1;
            }
        }

        // Smoothly dampen between values
        transform.position = transform.position.dampen(target, deltaTime);
        transform.scale = transform.scale.dampen(targetScale, deltaTime, scaleSpeed);
        curRotation = curRotation.dampen(targetRotation, deltaTime);
        transform.rotation = quat.euler_rotation(curRotation.x, curRotation.y, curRotation.z);

        // Reset hovering state
        isHovering = false;
    }
}