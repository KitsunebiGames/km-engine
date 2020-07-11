/*
    Copyright © 2020, Luna Nielsen
    Distributed under the 2-Clause BSD License, see LICENSE file.
    
    Authors: Luna Nielsen
*/
module engine.render.tile;
import engine;
import std.conv;
import std.exception;
import std.format : format;

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
    static TextureAtlas tileAtlas;

    static Shader TileShader;
    static GLint TileShaderMVP;
    enum relWidth = MahjongTileWidth/2f;
    enum relHeight = MahjongTileHeight/2f;
    enum relLength = MahjongTileLength/2f;
    static float[12*3*3] tileVerts;
    static GLuint tileVBO;
    GLuint vao;

    bool tilePopulated;
    void initTile() {

        glGenVertexArrays(1, &vao);
        glBindVertexArray(vao);

        // Populate verticies
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

        glGenBuffers(1, &tileVBO);
        glBindBuffer(GL_ARRAY_BUFFER, tileVBO);
        glBufferData(GL_ARRAY_BUFFER, float.sizeof*tileVerts.length, tileVerts.ptr, GL_STATIC_DRAW);
    }

    void loadTileset(string tilesetName="default") {

        // TODO: size the atlas based on the size of tiles
        tileAtlas = new TextureAtlas(vec2i(2048, 2048));

        import std.conv : to;
        import std.path : buildPath;

        tileAtlas.add("TileCap", buildPath("assets", "tiles", tilesetName, "TileCap.png"));
        tileAtlas.add("TileSide", buildPath("assets", "tiles", tilesetName, "TileSide.png"));
        tileAtlas.add("TileBack", buildPath("assets", "tiles", tilesetName, "TileBack.png"));
        
        foreach(i; 0..cast(int)TileType.ExtendedSetTileCount) {
            string name = to!string(cast(TileType)i);
            string path = buildPath("assets", "tiles", tilesetName, "Tile%s.png".format(name));
            try {

                // Try to add the tile, throw exception if we're out of space
                AtlasArea area = tileAtlas.add("Tile%s".format(name), path);
                enforce(area.uv.isFinite, "Out of space in texture atlas!");

            } catch(Exception ex) {
                AppLog.fatal("Tile", "%s: %s", ex.msg, path);
            }
        }

        tileAtlas.setFiltering(Filtering.Linear);
    }
}


/**
    A mahjong tile
*/
class Tile {
private:

    TileType type_;
    GLuint uvVBO;
    float[12*2*3] uvs;

    void genBuffer() {

        glGenBuffers(1, &uvVBO);
        genUVs();
        glBindBuffer(GL_ARRAY_BUFFER, uvVBO);
        glBufferData(GL_ARRAY_BUFFER, float.sizeof*uvs.length, uvs.ptr, GL_STATIC_DRAW);

    }

    void genUVs() {
        vec4 frontFace = tileAtlas["Tile%s".format(to!string(type_))].uv;
        vec4 backFace = tileAtlas["TileBack"].uv;
        vec4 capFace = tileAtlas["TileCap"].uv;
        vec4 sideFace = tileAtlas["TileSide"].uv;
        uvs = [
            // Front Face
            frontFace.x, frontFace.w,
            frontFace.z, frontFace.w,
            frontFace.x, frontFace.y,
            
            frontFace.z, frontFace.w,
            frontFace.z, frontFace.y,
            frontFace.x, frontFace.y,

            // Top Face
            capFace.x, capFace.w,
            capFace.z, capFace.w,
            capFace.x, capFace.y,
            
            capFace.z, capFace.w,
            capFace.z, capFace.y,
            capFace.x, capFace.y,

            // Back Face
            backFace.x, backFace.w,
            backFace.z, backFace.w,
            backFace.x, backFace.y,
            
            backFace.z, backFace.w,
            backFace.z, backFace.y,
            backFace.x, backFace.y,

            // Bottom Face
            capFace.x, capFace.w,
            capFace.z, capFace.w,
            capFace.x, capFace.y,
            
            capFace.z, capFace.w,
            capFace.z, capFace.y,
            capFace.x, capFace.y,

            // Left Face
            sideFace.x, sideFace.w,
            sideFace.z, sideFace.w,
            sideFace.x, sideFace.y,
            
            sideFace.z, sideFace.w,
            sideFace.z, sideFace.y,
            sideFace.x, sideFace.y,

            // Right Face
            sideFace.x, sideFace.w,
            sideFace.z, sideFace.w,
            sideFace.x, sideFace.y,
            
            sideFace.z, sideFace.w,
            sideFace.z, sideFace.y,
            sideFace.x, sideFace.y,
        ];
    }

public:
    /**
        The tile's transform
    */
    Transform transform;

    /**
        The tile's collider
    */
    OBB collider;

    ~this() {
        glDeleteBuffers(1, &uvVBO);
    }

    /**
        Construct a new tile
    */
    this(TileType type_) {
        this.type_ = type_;

        // Populate tile atlas if needed
        if (tileAtlas is null) {
            initTile();
            loadTileset();
        }

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

    /**
        Gets the type of the tile
    */
    TileType type() {
        return type_;
    }

    /**
        Updates the collider
    */
    void updateCollider() {
        collider.position = transform.position;
        collider.size = vec3(MahjongTileWidth/2, MahjongTileHeight/2, MahjongTileLength/2);
        collider.rotation = transform.rotation;
    }

    /**
        Begins drawing tiles
    */
    static void begin() {
        // Prepare shader
        TileShader.use();
        tileAtlas.bind();

        // Vertex Buffer
        glEnableVertexAttribArray(0);
        glBindBuffer(GL_ARRAY_BUFFER, tileVBO);
        glVertexAttribPointer(
            0,
            3,
            GL_FLOAT,
            GL_FALSE,
            0,
            null
        );

        glEnableVertexAttribArray(1);
    }

    static void end() {
        glDisableVertexAttribArray(0);
        glDisableVertexAttribArray(1);
    }

    /**
        Draws the tile
    */
    void draw(Camera camera) {
        TileShader.setUniform(TileShaderMVP, camera.matrix*transform.matrix);

        // UVs
        glBindBuffer(GL_ARRAY_BUFFER, uvVBO);
        glVertexAttribPointer(
            1,
            2,
            GL_FLOAT,
            GL_FALSE,
            0,
            null
        );
        glDrawArrays(GL_TRIANGLES, 0, cast(int)tileVerts.length);
    }

    /**
        Draws the tile on UI
    */
    void drawInUI(Camera2D camera, vec2 position, float scale = 1, quat rotation = quat.identity) {
        TileShader.setUniform(TileShaderMVP, 
            camera.matrix *
            mat4.translation(position.x, position.y, -((MahjongTileLength*MahjongScaleFactor)*scale)) * 
            rotation.to_matrix!(4, 4) *
            mat4.scaling(scale*MahjongScaleFactor, -(scale*MahjongScaleFactor), scale*MahjongScaleFactor)
        );

        // UVs
        glBindBuffer(GL_ARRAY_BUFFER, uvVBO);
        glVertexAttribPointer(
            1,
            2,
            GL_FLOAT,
            GL_FALSE,
            0,
            null
        );
        glDrawArrays(GL_TRIANGLES, 0, cast(int)tileVerts.length);
    }
}