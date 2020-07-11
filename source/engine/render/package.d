/*
    Copyright © 2020, Luna Nielsen
    Distributed under the 2-Clause BSD License, see LICENSE file.
    
    Authors: Luna Nielsen
*/
module engine.render;
public import bindbc.opengl;
public import engine.render.shader;
public import engine.render.tile;
public import engine.render.texture;
public import engine.render.batcher;

void initRender() {
    
    // OpenGL prep stuff
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    //glEnable(GL_CULL_FACE);
    glEnable(GL_DEPTH_TEST);
    glDepthFunc(GL_LESS);

    GameBatch = new SpriteBatch();
}