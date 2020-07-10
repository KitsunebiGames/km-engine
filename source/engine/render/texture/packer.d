/*
    Copyright © 2020, Luna Nielsen
    Distributed under the 2-Clause BSD License, see LICENSE file.
    
    Authors: Luna Nielsen
*/
module engine.render.texture.packer;
import gl3n.linalg;
import std.exception;

/++
    Node used in generating a texture.
+/
struct FNode {
    this(vec2i origin, vec2i size) {
        this.origin = origin;
        this.size = size;
        this.empty = true;
        this.left = null;
        this.right = null;
    }

    /// Origin of texture
    vec2i origin;
    
    /// Size of texture
    vec2i size;

    /// Wether the node is taken
    bool empty = true;

    /// Node branch left
    FNode* left;

    /// Node branch right
    FNode* right;
}

/++
    Packing algorithm implementation
+/
class TexturePacker {
    /// Size of texture so far
    vec2i textureSize;

    /// The output buffer
    ubyte[] buffer;

    /// The root node for the packing
    FNode* root;

    this() {
        root = new FNode(vec2i(0, 0), vec2i(int.max, int.max));
        textureSize = vec2i(1024, 1024);
        buffer = new ubyte[](1024*1024);
    }

    /++
        Packing algorithm

        Based on the packing algorithm from straypixels.net
        https://straypixels.net/texture-packing-for-fonts/
    +/
    FNode* pack(FNode* node, vec2i size) {
        if (!node.empty) {
            return null;
        } else if (node.left !is null && node.right !is null) {
            FNode* rval = pack(node.left, size);
            return rval !is null ? rval : pack(node.right, size);
        } else {
            vec2i realSize = vec2i(node.size.x, node.size.y);

            // Calculate actual size if on boundary
            if (node.origin.x + node.size.x == int.max) {
                realSize.x = textureSize.x-node.origin.x;
            }
            if (node.origin.y + node.size.y == int.max) {
                realSize.y = textureSize.x-node.origin.y;
            }

            
            if (node.size.x == size.x && node.size.y == size.y) {
                // Size is perfect, pack here
                node.empty = false;
                return node;
            }

            // Not big enough?
            if (realSize.x < size.x || realSize.y < size.y) {
                return null;
            }

            FNode* left;
            FNode* right;

            vec2i remain = vec2i(realSize.x - size.x, realSize.y - size.y);
            bool vsplit = remain.x < remain.y;
            if (remain.x == 0 && remain.y == 0) {
                // Edgecase, hitting border of texture atlas perfectly, split at border instead
                if (node.size.x > node.size.y) vsplit = false;
                else vsplit = true;
            }

            if (vsplit) {
                left = new FNode(node.origin, vec2i(node.size.x, size.y));
                right = new FNode(  vec2i(node.origin.x, node.origin.y + size.y), 
                                    vec2i(node.size.x, node.size.y - size.y));
            } else {
                left = new FNode(node.origin, vec2i(size.x, node.size.y));
                right = new FNode(  vec2i(node.origin.x + size.x, node.origin.y), 
                                    vec2i(node.size.x - size.x, node.size.y));
            }

            node.left = left;
            node.right = right;
            return pack(node.left, size);
        }
    }

    void resizeBuffer(vec2i newSize) {
        ubyte[] newBuffer = new ubyte[](newSize.x*newSize.y);
        foreach(y; 0..textureSize.y) {
            foreach(x; 0..textureSize.x) {
                newBuffer[y * newSize.x + x] = buffer[y * textureSize.x + x];
            }
        }

        textureSize = newSize;
        buffer = newBuffer;
    }

    /++
        Pack a texture

        Returns the position that the texture can be found at.
    +/
    vec2i packTexture(ubyte[] textureBuffer, vec2i size) {
        FNode* node = pack(root, size);
        if (node == null) {
            this.resizeBuffer(vec2i(textureSize.x*2, textureSize.y*2));
            node = pack(root, size);

            enforce(node !is null, "Was unable to pack texture!");
        }

        enforce(size.x == node.size.x, "Sizes did not match! This is as bug in the texture packer.");
        enforce(size.y == node.size.y, "Sizes did not match! This is as bug in the texture packer.");

        foreach (ly; 0..size.y) {
            foreach(lx; 0..size.x) {
                int y = cast(int)node.origin.y + cast(int)ly;
                int x = cast(int)node.origin.x + cast(int)lx;
                this.buffer[y * textureSize.x + x] = textureBuffer[ly * size.x + lx];
            }
        }

        return node.origin;
    }
}