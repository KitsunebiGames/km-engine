/*
    Copyright © 2020, Luna Nielsen
    Distributed under the 2-Clause BSD License, see LICENSE file.
    
    Authors: Luna Nielsen
*/
#version 330
uniform mat4 mvp;
in vec3 verts;
out vec3 vertPos;

void main() {
    gl_Position = mvp * vec4(verts.xyz, 1);
    vertPos = verts.xyz;
}