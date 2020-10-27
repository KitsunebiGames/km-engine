/*
    Copyright © 2020, Luna Nielsen
    Distributed under the 2-Clause BSD License, see LICENSE file.
    
    Authors: Luna Nielsen
*/
module engine.vn.render.dialg;
import engine;
import std.conv;
import std.string : split;
import std.random;

private struct textInstr {
    dstring instr;
    dstring value;
}

private textInstr parseInstr(dstring txt) {
    textInstr instr;
    instr.instr = txt[0..2];
    instr.value = txt[2..$];
    return instr;
}

/**
    Renderer for visual novel dialogue, supports slow-typing
*/
class DialogueRenderer {
private:
    dstring current;
    size_t rendOffset = 0;

    double accum = 0;
    double timeout = 0.1;

    double sleep = 0;

    bool requestHide = false;

public:

    /**
        Gets the current text buffer being rendered
    */
    dstring currentTextBuffer() {
        return current;
    }

    /**
        Whether the text requested for the dialogue to be hidden
    */
    bool isHidingRequested() {
        return requestHide;
    }

    /**
        Skip to end of dialogue
    */
    void skip() {
        if (!done) {
            rendOffset = current.length;
        }
    }

    /**
        Gets whether the renderer is empty
    */
    bool empty() {
        return current.length == 0;
    }

    /**
        Gets whether this line is done
    */
    bool done() {
        return rendOffset == current.length;
    }

    /**
        Push text for rendering
    */
    void pushText(dstring text) {
        current = text;
        rendOffset = 0;
        accum = 0;
    }

    void update() {


        // Don't try to uupdate empty text
        if (empty) return;

        // Accumulator
        accum += 1*deltaTime;
        
        // Handle sleeping
        if (sleep > 0) {
            if (accum >= sleep) {
                sleep = 0;
                accum = 0;
                while(!done && current[rendOffset] != ']') rendOffset++;
                rendOffset++;
            }
            else return;
        }

        // If we're past the end for some reason, fix it

        // Handle slowtyping text
        if (accum >= timeout) {
            accum -= timeout;
            if (!done) {
                if (current[rendOffset] == '\n') rendOffset++;

                size_t i = rendOffset;

                // Parse time changes
                while (i < current.length-3 && current[i] == '[' && current[i+1] == '&') {
                    i += 2;
                    
                    while(i < current.length && current[i] != ']') i++;
                    i++;

                    // Get the instruction
                    textInstr instr = parseInstr(current[rendOffset+2..i-1]);
                    switch(instr.instr) {
                        case "tm"d:
                            timeout = parse!double(instr.value);
                            break;
                        case "sl"d:
                            sleep = parse!double(instr.value);
                            return;
                        case "rh"d:
                            requestHide = true;
                            break;
                        case "rs"d:
                            requestHide = false;
                            break;
                        default: break;
                    }
                }

                // Extra increment
                if (i < current.length) i++;
                rendOffset = i;
            }
        }
    }

    void draw(vec2 at, int size = 48) {

        // Don't try to render empty text
        if (empty) return;

        // Always flush drawing when done
        scope(exit) UI.UIFont.flush();
        
        // Setup
        UI.UIFont.changeSize(size);
        vec2 metrics = UI.UIFont.getMetrics();
        at += vec2(metrics.x/2, metrics.y/2);;
        vec2 cursor = at;
        int shake = 0;
        int wave = 0;
        int waveSpeed = 5;
        bool waveRot = false;
        vec4 color = vec4(1, 1, 1, 1);
        for(int i = 0; i < rendOffset; i++) {

            // Values for this iteration
            dchar c = current[i];
            vec2 advance = UI.UIFont.advance(c);

            // Parse mode changes
            if (i < current.length-3) {
                while (current[i] == '[' && current[i+1] == '&') {
                    i += 2;

                    // Go till end of instruction
                    size_t startOffset = i;
                    while(i != current.length-1 && current[i] != ']') i++;
                    i++;

                    // Get the instruction
                    textInstr instr = parseInstr(current[startOffset..i-1]);
                    switch(instr.instr) {
                        case "cl"d:

                            // Handle clear
                            if (instr.value == "clear") {
                                color = vec4(1, 1, 1, 1);
                                break;
                            }

                            // Try to figure out color
                            dstring[] vals = instr.value.split(',');
                            if (vals.length != 3) break;

                            // Parse colors
                            color.r = parse!float(vals[0]);
                            color.g = parse!float(vals[1]);
                            color.b = parse!float(vals[2]);
                            break;

                        case "wv"d:
                            // Handle clear
                            if (instr.value == "clear") {
                                wave = 0;
                                break;
                            }
                            
                            shake = 0;
                            wave = parse!int(instr.value);
                            break;

                        case "wr"d:
                            waveRot = parse!bool(instr.value);
                            break;

                        case "ws"d:
                            // Handle clear
                            if (instr.value == "clear") {
                                waveSpeed = 5;
                                break;
                            }
                            
                            waveSpeed = parse!int(instr.value);
                            break;

                        case "sh"d:
                            // Handle clear
                            if (instr.value == "clear") {
                                shake = 0;
                                break;
                            }

                            wave = 0;
                            shake = parse!int(instr.value);
                            break;

                        default: break;
                    }
                    
                    if (i < current.length) {
                        c = current[i];
                        advance = UI.UIFont.advance(c);
                    } else return;
                }
            }

            // Handle newlines
            if (c == '\n') {
                cursor.x = at.x;
                cursor.y += metrics.y;
                continue;
            }

            // Skip all the parsing stuff for whitespace
            if (c == ' ') {
                cursor.x += advance.x;
                continue;
            }

            vec2 lCursor = cursor;
            float rot = 0;

            if (wave > 0) {
                cursor.y += sin((currTime()+cast(float)i)*waveSpeed)*wave;
                if (waveRot) rot -= sin((currTime()+cast(float)i)*waveSpeed)*(0.015*wave);
            }
            if (shake > 0) {
                cursor.x += ((uniform01()*2)-1)*shake;
                cursor.y += ((uniform01()*2)-1)*shake;
            }
            

            // Draw font
            UI.UIFont.draw(c, cursor, vec2(advance.x/2, metrics.y/2), rot, color);
            cursor = lCursor;
            cursor.x += advance.x;
        }
    }
}