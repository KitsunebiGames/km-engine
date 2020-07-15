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

private {
    static Shader TileShader;
    static GLint TileShaderMVP;
}

/**
    Initializes the tile mesh system
*/
void initTileMesh() {

    // Load tile shader if needed
    if (TileShader is null) {
        TileShader = new Shader(import("shaders/tile.vert"), import("shaders/tile.frag"));
        TileShader.use();
        TileShaderMVP = TileShader.getUniformLocation("mvp");
    }
}

/**
    The side of the tile mesh
*/
enum TileMeshSide {
    /// Font of the tile mesh
    Front,

    /// Back of the tile mesh
    Back,

    // Left/right sides of the tile mesh
    Side,

    // Top/bottom sides of the tile mesh
    Cap
}

private static GLuint vao;

/**
    A mesh for a tile
*/
class TileMesh {
private:
    TextureAtlas atlas;


    vec3 size;
    float[12*3*3] verts;
    float[12*2*3] uvs;
    GLuint uvId;
    GLuint vdId;

    void genVerts() {

        // We want to generate the model so that origin is in the center
        immutable(float) relWidth = size.x/2;
        immutable(float) relHeight = size.y/2;
        immutable(float) relLength = size.z/2;

        // Populate verticies
        verts = [
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

    void genUV(TileMeshSide side, AtlasArea area) {
        immutable(vec4) faceUV = area.uv;
        switch(side) {
            case TileMeshSide.Front:
                uvs[0..12] = [
                    faceUV.x, faceUV.w,
                    faceUV.z, faceUV.w,
                    faceUV.x, faceUV.y,
                    
                    faceUV.z, faceUV.w,
                    faceUV.z, faceUV.y,
                    faceUV.x, faceUV.y,
                ];
                break;

            case TileMeshSide.Back:
                uvs[24..36] = [
                    faceUV.x, faceUV.w,
                    faceUV.z, faceUV.w,
                    faceUV.x, faceUV.y,
                    
                    faceUV.z, faceUV.w,
                    faceUV.z, faceUV.y,
                    faceUV.x, faceUV.y,
                ];

                break;

            case TileMeshSide.Side:
                uvs[48..60] = [
                    faceUV.x, faceUV.w,
                    faceUV.z, faceUV.w,
                    faceUV.x, faceUV.y,
                    
                    faceUV.z, faceUV.w,
                    faceUV.z, faceUV.y,
                    faceUV.x, faceUV.y,
                ];
                uvs[60..72] = [
                    faceUV.x, faceUV.w,
                    faceUV.z, faceUV.w,
                    faceUV.x, faceUV.y,
                    
                    faceUV.z, faceUV.w,
                    faceUV.z, faceUV.y,
                    faceUV.x, faceUV.y,
                ];
                break;

            case TileMeshSide.Cap:
                uvs[12..24] = [
                    faceUV.x, faceUV.w,
                    faceUV.z, faceUV.w,
                    faceUV.x, faceUV.y,
                    
                    faceUV.z, faceUV.w,
                    faceUV.z, faceUV.y,
                    faceUV.x, faceUV.y,
                ];
                uvs[36..48] = [
                    faceUV.x, faceUV.w,
                    faceUV.z, faceUV.w,
                    faceUV.x, faceUV.y,
                    
                    faceUV.z, faceUV.w,
                    faceUV.z, faceUV.y,
                    faceUV.x, faceUV.y,
                ];
                break;
            default: break;
        }
    }

    void initTile(string front, string back, string side, string cap) {
        
        // Gen new vao if needed
        if (vao == 0) glGenVertexArrays(1, &vao);
        glBindVertexArray(vao);

        glGenBuffers(1, &vdId);
        glGenBuffers(1, &uvId);

        genVerts();
        glBindBuffer(GL_ARRAY_BUFFER, vdId);
        glBufferData(GL_ARRAY_BUFFER, float.sizeof*verts.length, verts.ptr, GL_STATIC_DRAW);

        genUV(TileMeshSide.Front,   atlas[front]);
        genUV(TileMeshSide.Back,    atlas[back]);
        genUV(TileMeshSide.Side,    atlas[side]);
        genUV(TileMeshSide.Cap,     atlas[cap]);
        glBindBuffer(GL_ARRAY_BUFFER, uvId);
        glBufferData(GL_ARRAY_BUFFER, float.sizeof*uvs.length, uvs.ptr, GL_STATIC_DRAW);
    }

    void bind() {

        // Set vertex attributes
        glEnableVertexAttribArray(0);
        glEnableVertexAttribArray(1);
        glBindBuffer(GL_ARRAY_BUFFER, vdId);
        glVertexAttribPointer(
            0,
            3,
            GL_FLOAT,
            GL_FALSE,
            0,
            null
        );

        glBindBuffer(GL_ARRAY_BUFFER, uvId);
        glVertexAttribPointer(
            1,
            2,
            GL_FLOAT,
            GL_FALSE,
            0,
            null
        );
    }

public:

    /**
        Destructor
    */
    ~this() {
        glDeleteBuffers(1, &uvId);
        glDeleteBuffers(1, &vdId);
    }

    /**
        Construct a new tile
    */
    this(vec3 size, TextureAtlas atlas, string frontTexture, string backTexture, string sideTexture, string capTexture) {
        this.atlas = atlas;
        this.size = size;
        initTile(frontTexture, backTexture, sideTexture, capTexture);
    }

    /**
        Changes the texture of a side of the tile
    */
    void setTexture(TileMeshSide side, AtlasArea tex) {
        genUV(side, tex);
        glBindBuffer(GL_ARRAY_BUFFER, uvId);
        glBufferData(GL_ARRAY_BUFFER, float.sizeof*uvs.length, uvs.ptr, GL_STATIC_DRAW);
    }

    /**
        Begin rendering tiles
    */
    static void begin() {

        // Bind the vao
        glBindVertexArray(vao);
    }

    /**
        End rendering tiles
    */
    static void end() {
        glDisableVertexAttribArray(0);
        glDisableVertexAttribArray(1);
    }

    /**
        Draws the tile
    */
    void draw(Camera camera, mat4 transform) {
        
        bind();
        TileShader.use();
        atlas.bind();
        TileShader.setUniform(TileShaderMVP, camera.matrix*transform);
        glDrawArrays(GL_TRIANGLES, 0, cast(int)verts.length);
    }

    /**
        Draws the tile on a 2D plane
    */
    void draw2d(Camera2D camera, vec2 position, float scale = 1, quat rotation = quat.identity) {
        
        bind();
        TileShader.use();
        atlas.bind();
        TileShader.setUniform(TileShaderMVP, 
            camera.matrix *
            mat4.translation(position.x, position.y, -(size.z*scale)) * 
            rotation.to_matrix!(4, 4) *
            mat4.scaling(scale, -scale, scale)
        );

        glDrawArrays(GL_TRIANGLES, 0, cast(int)verts.length);
    }
}