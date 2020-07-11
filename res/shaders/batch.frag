/*
    Copyright © 2020, Luna Nielsen
    Distributed under the 2-Clause BSD License, see LICENSE file.
    
    Authors: Luna Nielsen
*/
#version 330
in vec2 texUVs;
out vec4 outColor;

uniform sampler2D tex;

void main() {
    vec2 texSize = vec2(textureSize(tex, 0));

    outColor = texture(tex, texUVs/texSize);
}