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
    dstring[] log;

    /**
        Adds action to log
    */
    void add(dstring action) {
        log ~= action;
    }

    /**
        Adds character saying something to log
    */
    void add(dstring c, dstring text) {
        
        // Just add action if we have no origin
        if (c.length == 0) {
            this.add(text);
            return;
        }

        // Add our dialogue
        log ~= "[&cl1,0.5,0.5]%s[&clclear]: %s"d.format(c, text);
    }
}