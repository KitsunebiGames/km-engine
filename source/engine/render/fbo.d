/*
    Copyright © 2020, Luna Nielsen
    Distributed under the 2-Clause BSD License, see LICENSE file.
    
    Authors: Luna Nielsen
*/
module engine.render.fbo;
import engine.render;
import engine.math;
import engine.core.window;

/**
    A framebuffer
*/
class Framebuffer {
private:
    Window window;

    vec2i size;
    vec2i realsize;

    GLuint fbo;
    GLuint color;
    GLuint depth;

package(engine):

    /**
        Gets the texture ID associated with the fbo
    */
    GLuint getTexId() {
        return color;
    }

public:

    /**
        The constructor
    */
    this(Window window, vec2i size) {
        this.window = window;
        this.size = size;
        this.realsize = size*2;
        
        // Bind FBO
        glGenFramebuffers(1, &fbo);
        glBindFramebuffer(GL_FRAMEBUFFER, fbo);

        // Enable blending, etc.
        glEnable(GL_BLEND);
        glBlendFuncSeparate(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA, GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
        glEnable(GL_CULL_FACE);
        glEnable(GL_DEPTH_TEST);
        glDepthFunc(GL_LESS);

        // Generate texture
        glGenTextures(1, &color);
        glBindTexture(GL_TEXTURE_2D, color);
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, realsize.x, realsize.y, 0, GL_RGBA, GL_UNSIGNED_BYTE, null);
        
        // Set up texture parameters
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);

        // Generate depth buffer
        glGenRenderbuffers(1, &depth);
        glBindRenderbuffer(GL_RENDERBUFFER, depth);
        glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT, realsize.x, realsize.y);

        // Configure framebuffer
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, depth);
        glFramebufferTexture(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, color, 0);
    }

    /**
        Bind the framebuffer
    */
    void bind() {
        glBindFramebuffer(GL_FRAMEBUFFER, fbo);
        kmViewport(0, 0, realsize.x, realsize.y);
        kmSetCameraTargetSize(size.x, size.y);
    }

    /**
        Unbind the framebuffer
    */
    void unbind() {
        glBindFramebuffer(GL_FRAMEBUFFER, 0);
        kmViewport(0, 0, window.width, window.height);
    }

    /**
        Renders the framebuffer to fit in the current viewport
    */
    void renderToFit() {
        double widthScale = cast(double)kmViewportWidth / cast(double)realWidth;
        double heightScale = cast(double)kmViewportHeight / cast(double)realHeight;
        double scale = min(widthScale, heightScale);

        vec4 bounds = vec4(
            0,
            0,
            realWidth*scale,
            realHeight*scale
        );

        if (widthScale > heightScale) bounds.x = (kmViewportWidth-bounds.z)/2;
        else if (heightScale > widthScale) bounds.y = (kmViewportHeight-bounds.w)/2;

        GameBatch.draw(this, bounds);
    }

    /**
        Width of framebuffer
    */
    int width() {
        return size.x;
    }

    /**
        Height of framebuffer
    */
    int height() {
        return size.y;
    }

    /**
        Real width of framebuffer
    */
    int realWidth() {
        return realsize.x;
    }

    /**
        Real height of framebuffer
    */
    int realHeight() {
        return realsize.y;
    }
}