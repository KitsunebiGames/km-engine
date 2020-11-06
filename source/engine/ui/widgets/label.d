/*
    Copyright © 2020, Luna Nielsen
    Distributed under the 2-Clause BSD License, see LICENSE file.
    
    Authors: Luna Nielsen
*/
module engine.ui.widgets.label;
import engine.ui;
import engine;

/**
    A label
*/
class Label : Widget {
private:

protected:
    override {
        /**
            Code run when updating the widget
        */
        void onUpdate() { }

        /**
            Code run when drawing
        */
        void onDraw() {
            GameFont.changeSize(size);
            GameFont.draw(this.text, vec2(area.x, area.y));
            GameFont.flush();
        }
    }
    
public:

    /**
        The text buffer for the label
    */
    dstring text;

    /**
        The font size
    */
    int size = 24;

    this(T)(T text, int size = 24) if (isString!T) {
        super("Label");

        this.text = text.toEngineString();
        this.size = size;
    }

    /**
        Set the text of the label
        This function supports UTF8 text
    */
    void setText(T)(T text) if (isString!T) {
        this.text = text.toEngineString();
    }

override:

    /**
        Area of the widget
    */
    vec4 area() {
        vec4 sArea = scissorArea();
        return vec4(sArea.x-4, sArea.y-4, sArea.z+8, sArea.w+8);
    }

    /**
        Area in which the widget cuts out child widgets
    */
    vec4i scissorArea() {
        GameFont.changeSize(size);
        vec2 measure = GameFont.measure(text);
        vec2 pos = this.calculatedPosition();
        return vec4i(
            cast(int)pos.x, 
            cast(int)pos.y, 
            cast(int)measure.x, 
            cast(int)measure.y
        );
    }
}
