/*
    Copyright © 2020, Luna Nielsen
    Distributed under the 2-Clause BSD License, see LICENSE file.
    
    Authors: Luna Nielsen
*/
module engine.render.piece;

/**
    Width of tile (A2 in cm)
*/
enum MahjongTileWidth = 0.20;

/**
    Height of tile (A2 in cm)
*/
enum MahjongTileHeight = 0.35;

/**
    Length/Depth of tile (A2 in cm)
*/
enum MahjongTileLength = 0.26;

/**
    Types of tiles in a Mahjong set
    A set consists of:
    - 9 Dots/Coins (1-9)
    - 9 Bams/Bamboos (1-9)
    - 9 Craks/Kanji (1-9)
    - 3 Dragons (1-3, Red, Green, White)
    - 4 Winds (1-4, East, South, West, North)
    - 4 Flowers (1-4, Plum, Orchid, Bamboo and Chrysanthemum)
    - 4 Seasons (1-4, Spring, Summer, Autmn, Winter)
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
enum TileType {
    
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
    Flower1,

    /// 🀣
    Flower2,

    /// 🀤
    Flower3,

    /// 🀥
    Flower4,

    /// 🀦
    Spring,

    /// 🀧
    Summer,

    /// 🀨
    Autmn,

    /// 🀩
    Winter,

    /// 🀪
    Joker,

    /// Count of tiles in base set
    BaseSetTileCount,

    /// Red general purpose tile
    RedTile,

    /// Green general purpose tile
    GreenTile,

    /// Blue general purpose tile
    BlueTile,

    /// Orange general purpose tile
    OrangeTile,

    /// Pink general purpose tile
    PinkTile,

    /// June general purpose tile
    FoxJune,

    /// April general purpose tile
    FoxApril,

    /// Mei general purpose tile
    FoxMei,

    /// Count of tiles in extended set
    ExtendedSetTileCount
}

/**
    A mahjong tile
*/
class Tile {
private:
    float[] verticies;
    float[] uvs;

    void genVerticies() {
        verticies = [

        ];

        
    }

public:

}