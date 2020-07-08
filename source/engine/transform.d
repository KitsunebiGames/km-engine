/*
    Copyright © 2020, Luna Nielsen
    Distributed under the 2-Clause BSD License, see LICENSE file.
    
    Authors: Luna Nielsen
*/
module engine.transform;
import gl3n.linalg;

/**
    A 3D transform
*/
class Transform {
private:
    Transform parent;

    // Generated matrix
    mat4 g_matrix() {
        return rotation.to_matrix!(4, 4) * mat4.scaling(scale.x, scale.y, scale.z) * mat4.translation(position);
    }

public:

    /**
        Create a new 3D transform
    */
    this(Transform parent = null) {
        this(vec3(0, 0, 0), vec3(1, 1, 1), quat.identity, parent);
    }

    /**
        Create a new 3D transform
    */
    this(vec3 position, Transform parent = null) {
        this(position, vec3(1, 1, 1), quat.identity, parent);
    }

    /**
        Create a new 3D transform
    */
    this(vec3 position, vec3 scale, Transform parent = null) {
        this(position, scale, quat.identity, parent);
    }

    /**
        Create a new 3D transform
    */
    this(vec3 position, vec3 scale, quat rotation, Transform parent = null) {
        this.parent = parent;
        this.position = position;
        this.scale = scale;
        this.rotation = rotation;
    }

    /**
        Position of transform
    */
    vec3 position;

    /**
        Scale of transform
    */
    vec3 scale;

    /**
        Rotation of transform
    */
    quat rotation;

    /**
        Gets the calculated matrix for this transform
    */
    mat4 matrix() {
        if (parent is null) return g_matrix;
        return g_matrix*parent.matrix;
    }
}

/**
    A 2D transform
*/
class Transform2D {
private:
    Transform2D parent;

    // Generated matrix
    mat4 g_matrix() {
        return 
            mat4.zrotation(rotation) * 
            mat4.scaling(scale.x, scale.y, 1) * 
            mat4.translation(position.x, position.y, 0);
    }

public:

    /**
        Position of transform
    */
    vec2 position;

    /**
        Scale of transform
    */
    vec2 scale;

    /**
        Rotation of transform
    */
    float rotation;

    /**
        Gets the calculated matrix for this transform
    */
    mat4 matrix() {
        return g_matrix*parent.matrix;
    }
}