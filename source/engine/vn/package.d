/*
    Visual Novel Subsystem

    Copyright © 2020, Luna Nielsen
    Distributed under the 2-Clause BSD License, see LICENSE file.
    
    Authors: Luna Nielsen
*/
module engine.vn;
import engine.vn.render;
public import engine.vn.log;
public import engine.vn.dialg;
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

    /**
        The dialogue manager
    */
    DialogueManager dialogue;

}