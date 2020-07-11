/*
    Copyright © 2020, Luna Nielsen
    Distributed under the 2-Clause BSD License, see LICENSE file.
    
    Authors: Luna Nielsen
*/
#version 330
uniform mat4 vp;
in vec2 verts;
in vec2 uvs;
in vec4 color;

out vec2 texUVs;
out vec4 exColor;

void main() {
    gl_Position = vp * vec4(verts.xy, 0, 1);
    texUVs = uvs;
    exColor = color;
}