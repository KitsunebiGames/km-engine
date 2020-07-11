/*
    Copyright © 2020, Luna Nielsen
    Distributed under the 2-Clause BSD License, see LICENSE file.
    
    Authors: Luna Nielsen
*/
module engine.math.obb;
import gl3n.linalg;

/**
    Oriented bounding box
*/
struct OBB {
public:
    /**
        Position of the OBB
    */
    vec3 position;

    /**
        Rotation of the OBB
    */
    quat rotation;

    /**
        Extents of the OBB
    */
    vec3 size;

    /**
        Minimum extent of the OBB
    */
    vec3 min() {
        return vec3(rotation.to_matrix!(3, 3) * vec3(position.x-size.x, position.y-size.y, position.z-size.z));
    }

    /**
        Maximum extent of the OBB
    */
    vec3 max() {
        return vec3(rotation.to_matrix!(3, 3) * vec3(position.x+size.x, position.y+size.y, position.z+size.z));
    }

    /**
        Gets this OBB as a matrix
    */
    mat3 asMatrix() {
        return mat3.scaling(size.x, size.y, size.z) * rotation.to_matrix!(3, 3) * mat3.translation(position);
    }
}
