/*
    Copyright © 2020, Luna Nielsen
    Distributed under the 2-Clause BSD License, see LICENSE file.
    
    Authors: Luna Nielsen
*/
module engine.render.tile;
import engine;

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
    Autmn,

    /// 🀩
    Winter,

    /// 🀪
    Joker,

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

    /// Count of tiles in a set with only suits
    SuitsCount = Crak9+1,

    /// Count of tiles in a set with all bonus tiles
    SuitsAndBonusCount = Joker+1,

    /// Count of tiles in the extended set (Tiles added by Kitsune Mahjong)
    ExtendedSetTileCount = FoxMei+1
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
    static Shader TileShader;
    static GLint TileShaderMVP;
    enum relWidth = MahjongTileWidth/2f;
    enum relHeight = MahjongTileHeight/2f;
    enum relLength = MahjongTileLength/2f;
    static float[12*3*3] tileVerts;

    bool tilePopulated;
    void populateTile() {
        tileVerts = [
            // Front Face Tri 1
            -relWidth, -relHeight, relLength,
            relWidth, -relHeight, relLength,
            -relWidth, relHeight, relLength,

            // Front Face Tri 2
            relWidth, -relHeight, relLength,
            relWidth, relHeight, relLength,
            -relWidth, relHeight, relLength,

            // Top Face Tri 1
            -relWidth, relHeight, relLength,
            relWidth, relHeight, -relLength,
            -relWidth, relHeight, -relLength,

            // Top Face Tri 2
            -relWidth, relHeight, relLength,
            relWidth, relHeight, relLength,
            relWidth, relHeight, -relLength,

            // Back Face Tri 1
            -relWidth, relHeight, -relLength,
            relWidth, -relHeight, -relLength,
            -relWidth, -relHeight, -relLength,

            // Back Face Tri 2
            -relWidth, relHeight, -relLength,
            relWidth, relHeight, -relLength,
            relWidth, -relHeight, -relLength,

            // Bottom Face Tri 1
            -relWidth, -relHeight, -relLength,
            relWidth, -relHeight, -relLength,
            -relWidth, -relHeight, relLength,

            // Bottom Face Tri 2
            relWidth, -relHeight, -relLength,
            relWidth, -relHeight, relLength,
            -relWidth, -relHeight, relLength,

            // Left Face Tri 1
            -relWidth, -relHeight, -relLength,
            -relWidth, relHeight, relLength,
            -relWidth, relHeight, -relLength,

            // Left Face Tri 2
            -relWidth, -relHeight, relLength,
            -relWidth, relHeight, relLength,
            -relWidth, -relHeight, -relLength,

            // Right Face Tri 1
            relWidth, relHeight, -relLength,
            relWidth, relHeight, relLength,
            relWidth, -relHeight, -relLength,

            // Right Face Tri 2
            relWidth, -relHeight, -relLength,
            relWidth, relHeight, relLength,
            relWidth, -relHeight, relLength,
        ];
    }
}


/**
    A mahjong tile
*/
class Tile {
private:

    GLuint vao;
    GLuint vbo;

    float[] uvs;

    void genBuffer() {
        if (!tilePopulated) populateTile();

        glGenVertexArrays(1, &vao);
        glBindVertexArray(vao);

        glGenBuffers(1, &vbo);
        glBindBuffer(GL_ARRAY_BUFFER, vbo);
        glBufferData(GL_ARRAY_BUFFER, float.sizeof*tileVerts.length, tileVerts.ptr, GL_STATIC_DRAW);
    }

public:
    /**
        The tile's transform
    */
    Transform transform;

    /**
        Construct a new tile
    */
    this(TileType type) {

        // Generate OpenGL buffer
        genBuffer();

        // Load tile shader if needed
        if (TileShader is null) {
            TileShader = new Shader(import("shaders/tile.vert"), import("shaders/tile.frag"));
            TileShader.use();
            TileShaderMVP = TileShader.getUniformLocation("mvp");
        }

        // Make sure transform is assigned
        transform = new Transform();
    }

    static void beginShading() {
        // Prepare shader
        TileShader.use();
    }

    /**
        Draws the tile
    */
    void draw(Camera camera) {
        TileShader.setUniform(TileShaderMVP, camera.matrix*transform.matrix);

        glEnableVertexAttribArray(0);
        glBindBuffer(GL_ARRAY_BUFFER, vbo);
        glVertexAttribPointer(
            0,
            3,
            GL_FLOAT,
            GL_FALSE,
            0,
            null
        );
        glDrawArrays(GL_TRIANGLES, 0, cast(int)tileVerts.length);
        glDisableVertexAttribArray(0);
    }

    /**
        Draws the tile on UI
    */
    void drawInUI(UICamera camera) {

    }
}