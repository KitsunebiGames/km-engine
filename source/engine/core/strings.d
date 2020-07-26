/*
    Copyright © 2020, Luna Nielsen
    Distributed under the 2-Clause BSD License, see LICENSE file.
    
    Authors: Luna Nielsen
*/
module engine.core.strings;
import std.utf : toUTF32, toUTF16;

/**
    Convert any type of string to a engine usable string
*/
dstring toEngineString(T)(T str) if (isString!T) {
    static if (is(T == dstring)) return str;
    else return toUTF32(str); 
}

/**
    Convert any type of string to a windows compatible UTF16 string
*/
wstring toWin32String(T)(T str) if (isString!T) {
    static if (is(T == wstring)) return str;
    else return toUTF16(str);
}

/**
    Is true if the specified type T is a string
*/
enum isString(T) = is(T == string) || is (T == wstring) || is(T == dstring);