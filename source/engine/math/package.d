/*
    Copyright © 2020, Luna Nielsen
    Distributed under the 2-Clause BSD License, see LICENSE file.
    
    Authors: Luna Nielsen
*/
module engine.math;
public import engine.math.camera;
public import engine.math.transform;
public import engine.math.obb;
public import std.math;
public import gl3n.math;
public import gl3n.linalg;
public import gl3n.aabb;
public import gl3n.interpolate;

/**
    A basic ray
*/
struct Ray {
    /**
        Origin of the ray
    */
    vec3 origin;

    /**
        Direction of the ray (unit vector)
    */
    vec3 direction;
}

/**
    Casts a screen space ray from the mouse position
*/
Ray castScreenSpaceRay(vec2 mouse, vec2 viewSize, mat4 vp) {

    // Start of ray
    vec4 rayStart = vec4(
        (mouse.x/viewSize.x - 0.5) * 2.0, // Map to screen space coordinates -1 to 1
        -(mouse.y/viewSize.y - 0.5) * 2.0, // Map to screen space coordinates -1 to 1
        -1, // Near plane is -1 in NDC.
        1,
    );

    // End of ray
    vec4 rayEnd = vec4(
        (mouse.x/viewSize.x - 0.5) * 2.0,
        -(mouse.y/viewSize.y - 0.5) * 2.0,
        0,
        1,
    );

    // Do the matrix math transforming projection-view space in to model space
    mat4 vpInverse =        vp.inverse;
    vec4 rayStartWorld =    vpInverse * rayStart;   rayStartWorld /= rayStartWorld.w;
    vec4 rayEndWorld =      vpInverse * rayEnd;     rayEndWorld /= rayEndWorld.w;

    vec3 rayDir = (rayEndWorld - rayStartWorld).normalized;
    
    return Ray(vec3(rayStartWorld.xyz), rayDir);
}

/**
    Gets whether a ray is intersecting a bounding box
*/
bool isRayIntersecting(OBB boundingBox, Ray ray, mat4 modelmatrix, ref float iDist) {
    float min = 0f;
    float max = 100_000f;

    vec3 oobWorldspace = vec3(modelmatrix[3][0], modelmatrix[3][1], modelmatrix[3][2]);
    vec3 delta = oobWorldspace-ray.origin;

    {
        vec3 xaxis = vec3(modelmatrix[0][0], modelmatrix[0][1], modelmatrix[0][2]);
        float e = dot(xaxis, delta);
        float f = dot(ray.direction, xaxis);

        if (fabs(f) > 0.001f) {
            float t1 = (e+boundingBox.min.x)/f;
            float t2 = (e+boundingBox.max.x)/f;

            // Swap if t1 is larger than t2
            if (t1 > t2) {
                float w = t1;
                t1 = t2;
                t2 = w;
            }

            if (t2 < max) max = t2;
            if (t1 > min) min = t1;

            if (max < min) return false;
        } else {
            if (-e+boundingBox.min.x > 0f || -e+boundingBox.max.x < 0f) return false;
        }
    }

    {
        vec3 yaxis = vec3(modelmatrix[1][0], modelmatrix[1][1], modelmatrix[1][2]);
        float e = dot(yaxis, delta);
        float f = dot(ray.direction, yaxis);

        if (fabs(f) > 0.001f) {
            float t1 = (e+boundingBox.min.y)/f;
            float t2 = (e+boundingBox.max.y)/f;

            // Swap if t1 is larger than t2
            if (t1 > t2) {
                float w = t1;
                t1 = t2;
                t2 = w;
            }

            if (t2 < max) max = t2;
            if (t1 > min) min = t1;

            if (max < min) return false;
        } else {
            if (-e+boundingBox.min.y > 0f || -e+boundingBox.max.y < 0f) return false;
        }
    }

    {
        vec3 zaxis = vec3(modelmatrix[2][0], modelmatrix[2][1], modelmatrix[2][2]);
        float e = dot(zaxis, delta);
        float f = dot(ray.direction, zaxis);

        if (fabs(f) > 0.001f) {
            float t1 = (e+boundingBox.min.z)/f;
            float t2 = (e+boundingBox.max.z)/f;

            // Swap if t1 is larger than t2
            if (t1 > t2) {
                float w = t1;
                t1 = t2;
                t2 = w;
            }

            if (t2 < max) max = t2;
            if (t1 > min) min = t1;

            if (max < min) return false;
        } else {
            if (-e+boundingBox.min.z > 0f || -e+boundingBox.max.z < 0f) return false;
        }
    }
    
    iDist = min;
    return true;
}