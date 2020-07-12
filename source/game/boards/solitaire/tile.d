/*
    Copyright © 2020, Luna Nielsen
    Distributed under the 2-Clause BSD License, see LICENSE file.
    
    Authors: Luna Nielsen
*/
module game.boards.solitaire.tile;
import engine;
import game;
import game.tiles;
import game.tiles.mahjong;

/**
    A solitaire tile
*/
class SolTile : MahjongTile {
private:
    const vec3 takenTargetScale = vec3(0, 0, 0);
    const vec3 selectedTargetScale = vec3(0.9, 0.9, 0.9);
    const vec3 targetScale = vec3(1, 1, 1);

    enum AnimSelectSpeed = 2;
    enum AnimTakeSpeed = 4;

public:

    this(TileType type) {
        super(type);
    }

    /**
        Whether this tile is selected
    */
    bool selected;

    /**
        Whether the tile has been taken
    */
    bool taken;

    /**
        Whether the taken animation is done playing
    */
    bool takenAnimationDone;

    override void update() {
        super.update();

        // Skip out if we're done animating
        if (takenAnimationDone) return;

        if (taken) {
            if (transform.scale < takenTargetScale) {
                takenAnimationDone = true;
                transform.scale = takenTargetScale;
            }
            if (transform.scale > takenTargetScale) transform.scale -= vec3(deltaTime*AnimTakeSpeed);
            return;
        }

        if (selected) {

            if (transform.scale > selectedTargetScale) transform.scale -= vec3(deltaTime*AnimSelectSpeed);
            if (transform.scale < selectedTargetScale) transform.scale = selectedTargetScale;

        } else if (transform.scale < targetScale) {

            transform.scale += vec3(deltaTime*AnimSelectSpeed);
            if (transform.scale > targetScale) transform.scale = targetScale;

        }
    }
}