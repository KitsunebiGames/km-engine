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
    enum VertsCount = 6;
    enum DataLength = VecSize+UVSize;
    enum DataSize = DataLength*VertsCount;

    Shader spriteBatchShader;
    Camera2D batchCamera;

    vec2 transformVerts(vec2 position, mat4 matrix) {
        return vec2(matrix*vec4(position.x, position.y, 0, 1));
    }
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

    void addVertexData(vec2 position, vec2 uvs) {
        data[dataOffset..dataOffset+DataLength] = [position.x, position.y, uvs.x, uvs.y];
        dataOffset += DataLength;
    }

public:

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
        Draws the texture

        Remember to call flush after drawing all the textures you want

        Flush will automatically be called if your draws exceed the max count
        Flush will automatically be called if you queue an other texture
    */
    void draw(Texture texture, vec4 position, vec4 cutout = vec4.init, vec2 origin = vec2(0, 0), float rotation = 0f) {

        // Flush if neccesary
        if (dataOffset == DataSize*EntryCount) flush();
        if (texture != currentTexture) flush();

        // Update current texture
        currentTexture = texture;

        mat4 transform =
            mat4.translation(position.x, position.y, 0) *
            mat4.translation(origin.x, origin.y, 0) *
            mat4.zrotation(rotation) * 
            mat4.translation(-origin.x, -origin.y, 0) *
            mat4.scaling(position.z, position.w, 0);

        if (!cutout.isFinite) {
            cutout = vec4(0, 0, texture.width, texture.height);
        }

        // Triangle 1
        addVertexData(vec2(0, 1).transformVerts(transform), vec2(cutout.x, cutout.y+cutout.w));
        addVertexData(vec2(1, 0).transformVerts(transform), vec2(cutout.x+cutout.z, cutout.y));
        addVertexData(vec2(0, 0).transformVerts(transform), vec2(cutout.x, cutout.y));
        
        // Triangle 2
        addVertexData(vec2(0, 1).transformVerts(transform), vec2(cutout.x, cutout.y+cutout.w));
        addVertexData(vec2(1, 1).transformVerts(transform), vec2(cutout.x+cutout.z, cutout.y+cutout.w));
        addVertexData(vec2(1, 0).transformVerts(transform), vec2(cutout.x+cutout.z, cutout.y));

        tris += 2;
    }

    /**
        Flush the buffer
    */
    void flush() {
        // Don't draw empty textures
        if (currentTexture is null) return;

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

        // Draw the triangles
        glDrawArrays(GL_TRIANGLES, 0, cast(int)(tris*3));

        // Reset the batcher's state
        glDisableVertexAttribArray(0);
        glDisableVertexAttribArray(1);
        currentTexture = null;
        dataOffset = 0;
        tris = 0;
    }
}