/*
    Visual Novel Subsystem

    Copyright © 2020, Luna Nielsen
    Distributed under the 2-Clause BSD License, see LICENSE file.
    
    Authors: Luna Nielsen
*/
module engine.vn;
import engine.vn.render;
import engine.vn.log;
import engine;

/**
    Holds the current state of the Visual Novel system
*/
class VNState {
public:
    /**
        Music being played
    */
    Music music;

    /**
        Ambience loops being played
    */
    Music[] ambience;

    /**
        The layers
        0 - background
        1 - scene
        2 - foreground
    */
    Layer[3] background;

    /**
        The text log
    */
    VNLog log;

}