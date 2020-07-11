/*
    Copyright © 2020, Luna Nielsen
    Distributed under the 2-Clause BSD License, see LICENSE file.
    
    Authors: Luna Nielsen
*/
module game.boards.solitaire.tilegen;
import engine;
import game;
import std.random;
import std.conv;

/**
    Generation mode
*/
enum GenMode {
    /**
        Randomly selects the next tile to be generated
    */
    Random,

    /**
        Cycles over the tiles in the roster
    */
    Cycles
}

/**
    Generates tiles for Solitaire Mahjong

    Generation rules:
    + Each tile has to be generated in pairs
    + Tiles have to follow the max amount in their set
*/
class TileGenerator {
private:
    TileType currentType;
    int[TileType] generatedCount;
    int genIndex;

    void setNextType(GenMode mode) {
        TileType newType;

        bool valid = true;
        do {
            if (mode == GenMode.Random) {
                newType = cast(TileType)uniform(0, TileType.SuitsAndBonusCount-1);
            } else {
                newType = cast(TileType)((cast(int)currentType+1)%(TileType.SuitsAndBonusCount-1));
            }
            if (newType !in generatedCount) break;

            int counter = 0;
            valid = true;

            // Get the max count use for the tile
            if (newType <= TileType.Dot9) counter = cast(int)TileTypeCount.Dots;
            else if (newType <= TileType.Bam9) counter = cast(int)TileTypeCount.Bams;
            else if (newType <= TileType.Crak9) counter = cast(int)TileTypeCount.Craks;
            else if (newType <= TileType.WhiteDragon) counter = cast(int)TileTypeCount.Dragons;
            else if (newType <= TileType.NorthWind) counter = cast(int)TileTypeCount.Winds;
            else if (newType <= TileType.Bamboo) counter = cast(int)TileTypeCount.Flowers;
            else if (newType <= TileType.Winter) counter = cast(int)TileTypeCount.Seasons;
            else valid = false;

            // If it's not a valid use set valid to false.
            if(generatedCount[newType] >= counter) valid = false;

            if (!valid) {
                AppLog.info("debug", "%s already exists too much", to!string(newType));
            }
        } while (!valid);

        // Update the type
        currentType = newType;
    }

public:

    /**
        Does nothing rn other than instantiate this object
    */
    this() {

    }

    /**
        Gets the next tile
    */
    Tile getNext() {
        // Generate and find next pair if we're on an uneven generation step
        if (genIndex == 1) {
            Tile nextTile = new Tile(currentType);
            generatedCount[currentType]++;

            setNextType(GenMode.Cycles);
            genIndex = 0;
            return nextTile;
        }

        // We're on an even step just get the next tile
        genIndex++;
        generatedCount[currentType]++;
        return new Tile(currentType);
    }

    /**
        Clear the generator's internal state
    */
    void clear() {
        generatedCount.clear();
    }
}