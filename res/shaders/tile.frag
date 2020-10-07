/*
    Copyright © 2020, Luna Nielsen
    Distributed under the 2-Clause BSD License, see LICENSE file.
    
    Authors: Luna Nielsen
*/
#version 330
in vec2 texUVs;
out vec4 outColor;

uniform sampler2D tex;

uniform bool available;

void main() {
    outColor = texture(tex, texUVs);
    if (!available) {
        outColor = outColor * vec4(0.8, 0.8, 0.8, 1);
    }
}