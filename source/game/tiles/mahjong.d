/*
    Copyright © 2020, Luna Nielsen
    Distributed under the 2-Clause BSD License, see LICENSE file.
    
    Authors: Luna Nielsen
*/
module game.tiles.mahjong;
import game.tiles;
import engine;
import game;
import std.conv : text;

/**
    Width of tile (A2 in cm)
*/
enum MahjongTileWidth = 0.26;

/**
    Height of tile (A2 in cm)
*/
enum MahjongTileHeight = 0.35;

/**
    Length/Depth of tile (A2 in cm)
*/
enum MahjongTileLength = 0.20;

/**
    Scaling factor for a mahjong tile's width to be 1 pixel wide
*/
enum MahjongScaleFactor = 1/MahjongTileWidth;

/**
    Types of tiles in a Mahjong set
    A set consists of:
    - 9 Dots/Coins (1-9)
    - 9 Bams/Bamboos (1-9)
    - 9 Craks/Kanji (1-9)
    - 3 Dragons (Red, Green, White)
    - 4 Winds (East, South, West, North)
    - 4 Flowers (Plum, Orchid, Bamboo and Chrysanthemum)
    - 4 Seasons (Spring, Summer, Autumn, Winter)
    - Jokers

    Kitsune Mahjong on top has a few extra tiles special game boards may use for various purposes
    - Red Tile
    - Green Tile
    - Blue Tile
    - Orange Tile
    - Pink Tile
    - Fox June Tile (Tile with drawing of June on it)
    - Fox April Tile (Tile with drawing of April on it)
    - Fox Mei Tile (Tile with drawing of Mei on it)
*/
enum TileType : int {
    
    /// 🀙
    Dot1,
    
    /// 🀚
    Dot2,

    /// 🀛
    Dot3,

    /// 🀜
    Dot4,

    /// 🀝
    Dot5,

    /// 🀞
    Dot6,

    /// 🀟
    Dot7,

    /// 🀠
    Dot8,

    /// 🀡
    Dot9,

    /// 🀐
    Bam1,

    /// 🀑
    Bam2,

    /// 🀒
    Bam3,

    /// 🀓
    Bam4,

    /// 🀔
    Bam5,

    /// 🀕
    Bam6,

    /// 🀖
    Bam7,

    /// 🀗
    Bam8,

    /// 🀘
    Bam9,

    /// 🀇
    Crak1,

    /// 🀈
    Crak2,

    /// 🀉
    Crak3,

    /// 🀊
    Crak4,

    /// 🀋
    Crak5,

    /// 🀌
    Crak6,

    /// 🀍
    Crak7,

    /// 🀎
    Crak8,

    /// 🀏
    Crak9,

    /// 🀄
    RedDragon,

    /// 🀅
    GreenDragon,

    /// 🀆
    WhiteDragon,

    /// 🀀
    EastWind,

    /// 🀁
    SouthWind,

    // 🀂
    WestWind,

    /// 🀃
    NorthWind,

    /// 🀢
    Plum,

    /// 🀣
    Orchid,

    /// 🀤
    Chrysanthemum,

    /// 🀥
    Bamboo,

    /// 🀦
    Spring,

    /// 🀧
    Summer,

    /// 🀨
    Autumn,

    /// 🀩
    Winter,

    /// 🀪
    Joker,

    /// Red general purpose tile
    Red,

    /// Green general purpose tile
    Green,

    /// Blue general purpose tile
    Blue,

    /// Orange general purpose tile
    Orange,

    /// Pink general purpose tile
    Pink,

    /// June general purpose tile
    June,

    /// April general purpose tile
    April,

    /// Mei general purpose tile
    Mei,

    /// Count of tiles in a set with only suits
    SuitsCount = Crak9+1,

    /// Count of tiles in a set with all bonus tiles
    SuitsAndBonusCount = Joker+1,

    /// Count of tiles in the extended set (Tiles added by Kitsune Mahjong)
    ExtendedSetTileCount = Mei+1
}

/**
    How many of a type of tile there usually is in a set
*/
enum TileTypeCount : int {
    Dots = 4,
    Bams = 4,
    Craks = 4,
    Winds = 4,
    Dragons = 4,
    Flowers = 1,
    Seasons = 1
}

private {
    static TextureAtlas mahjongAtlas;

    void fillMahjongAtlas(string tileset) {
        import std.format : format;
        import std.path : buildPath;

        try {
            mahjongAtlas.add("TileCap", buildPath("assets", "tiles", tileset, "TileCap.png"));
            mahjongAtlas.add("TileSide", buildPath("assets", "tiles", tileset, "TileSide.png"));
            mahjongAtlas.add("TileBack", buildPath("assets", "tiles", tileset, "TileBack.png"));
            foreach(i; 0..cast(int)TileType.ExtendedSetTileCount) {    
                mahjongAtlas.add(
                    "Tile%s".format(text(cast(TileType)i)), 
                    buildPath("assets", "tiles", tileset, "Tile%s.png".format(text(cast(TileType)i)))
                );
            }
        } catch(Exception ex) {
            AppLog.fatal("MahjongTile", "Error loading tile set: %s", ex.msg);
        }
    }
}

/**
    Initialize mahjong
*/
void initMahjong(string tileset) {

    mahjongAtlas = new TextureAtlas(vec2i(2048, 2048));
    fillMahjongAtlas(tileset);
}

/**
    Change the active tile set
*/
void changeTileset(string tileset) {
    mahjongAtlas.clear();
    fillMahjongAtlas(tileset);
}

/**
    A mahjong tile
*/
class MahjongTile : Tile {
private:
    TileMesh mesh;
    TileType type_;

public:
    /**
        Constructor
    */
    this(TileType type) {
        super();
        this.type_ = type;
        mesh = new TileMesh(
            vec3(MahjongTileWidth, MahjongTileHeight, MahjongTileLength), 
            mahjongAtlas, 
            "Tile"~type.text,
            "TileBack",
            "TileSide",
            "TileCap"
        );
    }

    /**
        The type of the tile
    */
    TileType type() {
        return type_;
    }

    /**
        Draws the tile
    */
    override void draw(Camera camera) {
        mesh.draw(camera, transform);
    }

    /**
        Draw the tile in a 2D plane
    */
    override void draw2d(Camera2D camera, vec2 position, float scale = 1, quat rotation = quat.identity) {
        mesh.draw2d(camera, position, scale, rotation);
    }

    /**
        Update the tile
    */
    override void update() {
        collider.position = transform.position;
        collider.size = vec3(MahjongTileWidth/2, MahjongTileHeight/2, MahjongTileLength/2);
        collider.rotation = transform.rotation;
    }
}