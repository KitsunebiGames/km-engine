/*
    Copyright © 2020, Luna Nielsen
    Distributed under the 2-Clause BSD License, see LICENSE file.
    
    Authors: Luna Nielsen
*/
module engine.math.transform;
import gl3n.linalg;

/**
    A 3D transform
*/
class Transform {
private:
    Transform parent;

    // Generated matrix
    mat4 g_matrix() {
        return mat4.translation(position) * rotation.to_matrix!(4, 4) * mat4.scaling(scale.x, scale.y, scale.z);
    }

    // Generated matrix
    mat4 g_matrix_ns() {
        return mat4.translation(position) * rotation.to_matrix!(4, 4);
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
        Origin of transform
    */
    vec3 origin;

    /**
        Scale of transform
    */
    vec3 scale;

    /**
        Rotation of transform
    */
    quat rotation;

    /**
        Changes the transform's parent
    */
    void changeParent(Transform parent) {
        this.parent = parent;
    }

    /**
        Gets the calculated matrix for this transform
    */
    mat4 matrix() {
        if (parent is null) return g_matrix;
        return g_matrix*parent.matrix;
    }

    /**
        Gets the calculated matrix for this transform without any scaling applied
    */
    mat4 matrixUnscaled() {
        if (parent is null) return g_matrix_ns;
        return g_matrix_ns*parent.matrixUnscaled;
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
            mat4.translation(position.x, position.y, 0) * 
            mat4.translation(origin.x, origin.y, 0);
    }

public:

    /**
        Create a new 2D transform
    */
    this(Transform2D parent = null) {
        this(vec2(0, 0), vec2(0, 0), vec2(1, 1), 0, parent);
    }

    /**
        Create a new 2D transform
    */
    this(vec2 position, vec2 origin = vec2(0, 0), vec2 scale = vec2(1, 1), float rotation = 0, Transform2D parent = null) {
        this.position = position;
        this.origin = origin;
        this.scale = scale;
        this.rotation = rotation;
        this.parent = parent;
    }

    /**
        Position of transform
    */
    vec2 position;
    
    /**
        Position of the transform origin
    */
    vec2 origin;

    /**
        Scale of transform
    */
    vec2 scale;

    /**
        Rotation of transform
    */
    float rotation;

    /**
        Changes the transform's parent
    */
    void changeParent(Transform2D parent) {
        this.parent = parent;
    }

    /**
        Gets the calculated matrix for this transform
    */
    mat4 matrix() {
        if (parent is null) return g_matrix;
        return g_matrix*parent.matrix;
    }
}