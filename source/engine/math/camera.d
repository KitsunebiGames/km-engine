/*
    Copyright © 2020, Luna Nielsen
    Distributed under the 2-Clause BSD License, see LICENSE file.
    
    Authors: Luna Nielsen
*/
module engine.math.camera;
import gl3n.linalg;
import engine;

/**
    Camera for 3D space
*/
class Camera {
private:

    mat4 g_matrix() {
        return mat4.perspective(GameWindow.width, GameWindow.height, fov, 0.001, 100) * transform.matrix;
    }

public:

    this() {
        
    }

    float fov = 90;

    /**
        Transform of the position of the camera
    */
    Transform transform;

    /**
        Create 3D camera
    */
    this(Transform transform = null) {
        this.transform = transform is null ? new Transform() : transform;
    }

    /**
        The matrix for the camera
    */
    mat4 matrix() {
        return g_matrix();
    }
}

/**
    Orthographic camera for rendering UI

    TODO: extend camera as needed
*/
class Camera2D {
private:
    mat4 projection;

public:

    this() {
        position = vec2(0, 0);
    }

    /**
        Position of camera
    */
    vec2 position;

    /**
        Matrix for this camera
    */
    mat4 matrix() {
        int largestSize = max(GameWindow.width, GameWindow.height);
        return 
            mat4.orthographic(0f, cast(float)GameWindow.width, cast(float)GameWindow.height, 0, 0, largestSize) * 
            mat4.translation(position.x, position.y, -10);
    }
}