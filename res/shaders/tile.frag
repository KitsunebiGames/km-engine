/*
    Copyright © 2020, Luna Nielsen
    Distributed under the 2-Clause BSD License, see LICENSE file.
    
    Authors: Luna Nielsen
*/
#version 330
in vec3 vertPos;
out vec4 outColor;

void main() {

    outColor = vec4(vertPos.xyz+0.5, 1);
}