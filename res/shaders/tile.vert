/*
    Copyright © 2020, Luna Nielsen
    Distributed under the 2-Clause BSD License, see LICENSE file.
    
    Authors: Luna Nielsen
*/
#version 330
uniform mat4 mvp;
layout(location = 0) in vec3 verts;
layout(location = 1) in vec2 uvs;

out vec2 texUVs;

void main() {
    gl_Position = mvp * vec4(verts.xyz, 1);
    texUVs = uvs;
}