/*
    Copyright © 2020, Luna Nielsen
    Distributed under the 2-Clause BSD License, see LICENSE file.
    
    Authors: Luna Nielsen
*/
module engine.vn.log;
import std.format;

class VNLog {
public:
    /**
        The log
    */
    string[] log;

    /**
        Adds item to the log
    */
    void addText(string text) {
        log ~= "%s"d.format(text);
    }

    /**
        Adds character saying something to log
    */
    void addChar(string c, string text) {
        log ~= "[c=FFF0F0]%s[c=clear]: %s"d.format(c, text);
    }

    /**
        Adds action to log
    */
    void addAction(string action) {
        log ~= "[c=F0F0FF]%s[c=clear]"d.format(action);
    }
}