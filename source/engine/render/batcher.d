/*
    Copyright © 2020, Luna Nielsen
    Distributed under the 2-Clause BSD License, see LICENSE file.
    
    Authors: Luna Nielsen
*/
module engine.render.batcher;
import engine;

private {

    /// How many entries in a SpriteBatch
    enum EntryCount = 10_000;

    // Various variables that make it easier to reference sizes
    enum VecSize = 2;
    enum UVSize = 2;
    enum ColorSize = 4;
    enum VertsCount = 6;
    enum DataLength = VecSize+UVSize+ColorSize;
    enum DataSize = DataLength*VertsCount;

    Shader spriteBatchShader;
    Camera2D batchCamera;

    vec2 transformVerts(vec2 position, mat4 matrix) {
        return vec2(matrix*vec4(position.x, position.y, 0, 1));
    }
}

/**
    Global game sprite batcher
*/
static SpriteBatch GameBatch;

/**
    Sprite flipping
*/
enum SpriteFlip {
    None = 0,
    Horizontal = 1,
    Vertical = 2
}

/**
    Batches Texture objects for 2D drawing
*/
class SpriteBatch {
private:
    float[DataSize*EntryCount] data;
    size_t dataOffset;
    size_t tris;

    GLuint vao;
    GLuint buffer;
    GLint vp;

    Texture currentTexture;

    void addVertexData(vec2 position, vec2 uvs, vec4 color) {
        data[dataOffset..dataOffset+DataLength] = [position.x, position.y, uvs.x, uvs.y, color.x, color.y, color.z, color.w];
        dataOffset += DataLength;
    }

public:

    /**
        Constructor
    */
    this() {
        data = new float[DataSize*EntryCount];

        glGenVertexArrays(1, &vao);
        glBindVertexArray(vao);

        glGenBuffers(1, &buffer);
        glBindBuffer(GL_ARRAY_BUFFER, buffer);
        glBufferData(GL_ARRAY_BUFFER, float.sizeof*data.length, data.ptr, GL_DYNAMIC_DRAW);

        batchCamera = new Camera2D();
        spriteBatchShader = new Shader(import("shaders/batch.vert"), import("shaders/batch.frag"));
        vp = spriteBatchShader.getUniformLocation("vp");
    }

    /**
        Draws texture from atlas
    */
    void draw(string item, vec4 position, vec4 cutout = vec4.init, vec2 origin = vec2(0, 0), float rotation = 0f, SpriteFlip flip = SpriteFlip.None, vec4 color = vec4(1, 1, 1, 1)) {
        auto index = GameAtlas[item];
        draw(index, position, cutout, origin, rotation, flip, color);
    }

    /**
        Draws cached atlas index
    */
    void draw(AtlasIndex index, vec4 position, vec4 cutout = vec4.init, vec2 origin = vec2(0, 0), float rotation = 0f, SpriteFlip flip = SpriteFlip.None, vec4 color = vec4(1)) {
        
        vec4 fCutout = index.area;
        if (cutout.isFinite) {

            // Clamp the cutout to fit within the texture's area
            vec4 cutoutClamped = vec4(
                clamp(cutout.x, 0, index.area.z),
                clamp(cutout.y, 0, index.area.w),
                clamp(cutout.z, 0, index.area.z),
                clamp(cutout.w, 0, index.area.w),
            );
            
            // Cut in to the area
            fCutout = vec4(
                index.area.x+cutoutClamped.x,
                index.area.y+cutoutClamped.y,
                cutoutClamped.z,
                cutoutClamped.w,
            );
        }
        
        draw(index.texture, position, fCutout, origin, rotation, flip, color);
    }

    /**
        Draws the texture

        Remember to call flush after drawing all the textures you want

        Flush will automatically be called if your draws exceed the max count
        Flush will automatically be called if you queue an other texture
    */
    void draw(Texture texture, vec4 position, vec4 cutout = vec4.init, vec2 origin = vec2(0, 0), float rotation = 0f, SpriteFlip flip = SpriteFlip.None, vec4 color = vec4(1)) {

        // Flush if neccesary
        if (dataOffset == DataSize*EntryCount) flush();
        if (texture != currentTexture) flush();

        // Update current texture
        currentTexture = texture;

        mat4 transform =
            mat4.translation(-origin.x, -origin.y, 0) *
            mat4.translation(position.x, position.y, 0) *
            mat4.translation(origin.x, origin.y, 0) *
            mat4.zrotation(rotation) * 
            mat4.translation(-origin.x, -origin.y, 0) *
            mat4.scaling(position.z, position.w, 0);

        if (!cutout.isFinite) {
            cutout = vec4(0, 0, texture.width, texture.height);
        }

        vec4 uvArea = vec4(
            (flip & SpriteFlip.Horizontal) > 0 ? (cutout.x+cutout.z)-1.5 : (cutout.x)+0.8,
            (flip & SpriteFlip.Vertical)   > 0 ? (cutout.y+cutout.w)-1.5 : (cutout.y)+0.8,
            (flip & SpriteFlip.Horizontal) > 0 ? (cutout.x)+0.8 : (cutout.x+cutout.z)-1.5,
            (flip & SpriteFlip.Vertical)   > 0 ? (cutout.y)+0.8 : (cutout.y+cutout.w)-1.5,
        );

        // Triangle 1
        addVertexData(vec2(0, 1).transformVerts(transform), vec2(uvArea.x, uvArea.w), color);
        addVertexData(vec2(1, 0).transformVerts(transform), vec2(uvArea.z, uvArea.y), color);
        addVertexData(vec2(0, 0).transformVerts(transform), vec2(uvArea.x, uvArea.y), color);
        
        // Triangle 2
        addVertexData(vec2(0, 1).transformVerts(transform), vec2(uvArea.x, uvArea.w), color);
        addVertexData(vec2(1, 1).transformVerts(transform), vec2(uvArea.z, uvArea.w), color);
        addVertexData(vec2(1, 0).transformVerts(transform), vec2(uvArea.z, uvArea.y), color);

        tris += 2;
    }

    /**
        Flush the buffer
    */
    void flush() {

        // Disable depth testing for the batcher
        glDisable(GL_DEPTH_TEST);

        // Don't draw empty textures
        if (currentTexture is null) return;

        // Bind VAO
        glBindVertexArray(vao);

        // Bind just in case some shennanigans happen
        glBindBuffer(GL_ARRAY_BUFFER, buffer);

        // Update with this draw round's data
        glBufferSubData(GL_ARRAY_BUFFER, 0, dataOffset*float.sizeof, data.ptr);

        // Bind the texture
        currentTexture.bind();

        // Use our sprite batcher shader
        spriteBatchShader.use();
        spriteBatchShader.setUniform(vp, batchCamera.matrix);

        // Vertex Buffer
        glEnableVertexAttribArray(0);
        glVertexAttribPointer(
            0,
            VecSize,
            GL_FLOAT,
            GL_FALSE,
            DataLength*GLfloat.sizeof,
            null,
        );

        // UV Buffer
        glEnableVertexAttribArray(1);
        glVertexAttribPointer(
            1,
            UVSize,
            GL_FLOAT,
            GL_FALSE,
            DataLength*GLfloat.sizeof,
            cast(GLvoid*)(UVSize*GLfloat.sizeof),
        );

        // UV Buffer
        glEnableVertexAttribArray(2);
        glVertexAttribPointer(
            2,
            ColorSize,
            GL_FLOAT,
            GL_FALSE,
            DataLength*GLfloat.sizeof,
            cast(GLvoid*)((VecSize+UVSize)*GLfloat.sizeof),
        );

        // Draw the triangles
        glDrawArrays(GL_TRIANGLES, 0, cast(int)(tris*3));

        // Reset the batcher's state
        glDisableVertexAttribArray(0);
        glDisableVertexAttribArray(1);
        glDisableVertexAttribArray(2);
        currentTexture = null;
        dataOffset = 0;
        tris = 0;

        // Re-enable depth test Clear depth buffer
        glEnable(GL_DEPTH_TEST);
    }
}