/*
    Copyright © 2020, Luna Nielsen
    Distributed under the 2-Clause BSD License, see LICENSE file.
    
    Authors: Luna Nielsen
*/
module game.boards.solitaire.parser;
import game.boards.solitaire.field;
import engine;
import std.string;
import std.array;
import std.conv;

/**
    Parse the string data
*/
FieldData parse(string data) {
    FieldData outData;
    string[] lines = data.split("\n");
    outData.name = lines[0];
    foreach(i; 1..lines.length) {
        try {
            string[] values = lines[i].split(",");
            outData.slots ~= vec3i(values[0].to!int, values[1].to!int, values[2].to!int);
        } catch (Exception ex) {
            AppLog.fatal("Solitaire Mahjong Parser", "Error: %s: %s", i, ex.msg);
        }
    }
    return outData;
}
