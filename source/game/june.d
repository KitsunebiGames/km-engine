/*
    Copyright © 2020, Luna Nielsen
    Distributed under the 2-Clause BSD License, see LICENSE file.
    
    Authors: Luna Nielsen
*/
module game.june;
import game;
import engine;

/**
    June's state
*/
enum JuneState : string {
    Smile = "JuneSmile",
    Joy = "JuneJoy",
}

/**
    Foxgirl
*/
class June {
private:
    vec2 juneScale;

    JuneState state;
    AtlasIndex cached;
    
    float clearTimer = 0f;

public:

    /**
        Constructs a new June
    */
    this() {
        if (!GameAtlas.has("JuneJoy")) GameAtlas.add("JuneJoy", "assets/textures/june/junejoy.png");
        if (!GameAtlas.has("JuneSmile")) GameAtlas.add("JuneSmile", "assets/textures/june/junesmile.png");
    
        this.changeState(JuneState.Smile);
    }

    /**
        Change june's state and texture
    */
    void changeState(JuneState state) {
        this.state = state;
        cached = GameAtlas[cast(string)state];
    }

    /**
        Trigger june tile clear mode
    */
    void tileCleared() {
        clearTimer = 1;
        this.changeState(JuneState.Joy);
    }

    /**
        Update
    */
    void update() {
        juneScale = vec2(cached.area.z/5, cached.area.w/5);
        if (clearTimer > 0) {
            clearTimer -= deltaTime*1;
            if (clearTimer <= 0) {
                this.changeState(JuneState.Smile);
            }
        }
    }

    /**
        Draw june at the specified position
        
        bopping specifies whether june will be bopping up and down
    */
    void draw(bool bopping=true)(vec2 position, float rotation = 0) {

        // Draw June
        static if (bopping) {
            GameBatch.draw(
                cached,
                vec4(position.x, (position.y+4)-(sin(currTime)*4), juneScale.x, juneScale.y), 
                vec2(juneScale.x/2, juneScale.y),
                rotation,
            );
        } else {
            GameBatch.draw(
                cached,
                vec4(position.x, position.y, juneScale.x, juneScale.y), 
                vec2(juneScale.x/2, juneScale.y),
                rotation,
            );
        }

        GameBatch.flush();
    }
}