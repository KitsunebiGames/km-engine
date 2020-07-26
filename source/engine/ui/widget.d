/*
    Copyright © 2020, Luna Nielsen
    Distributed under the 2-Clause BSD License, see LICENSE file.
    
    Authors: Luna Nielsen
*/
module engine.ui.widget;
import engine;
import std.algorithm.mutation : remove;
import bindbc.opengl;
import std.exception;
import std.format;

/**
    A widget
*/
abstract class Widget {
private:
    string typeName;
    Widget parent_;
    Widget[] children;

    ptrdiff_t findSelfInParent() {
        
        // Can't find self if we don't have a parent
        if (parent_ is null) return -1;

        // Iterate through parent's children and find our instance
        foreach(i, widget; parent_.children) {
            if (widget == this) return i;
        }

        // We couldn't find ourselves?
        AppLog.warn("UI", "Widget %s could not find self in parent", this);
        return -1;
    }

protected:
    /**
        The parent widget
    */
    Widget parent() {
        return parent_;
    }

    /**
        Base widget instance requires type name
    */
    this(string type) {
        this.typeName = type;
    }

    /**
        Code run when updating the widget
    */
    abstract void onUpdate();

    /**
        Code run when drawing
    */
    abstract void onDraw();

public:

    /**
        Whether the widget is visible
    */
    bool visible = true;

    /**
        The position of the widget
    */
    vec2 position = vec2(0);

    /**
        Changes the parent of a widget to the specified other widget.
    */
    void changeParent(Widget newParent) {

        // Once we're done we need to update our bounds
        // We'll skip this if we threw an exception earlier
        scope(success) update();
        
        // Remove ourselves from our current parent if we have any
        if (parent_ !is null) {

            // Find ourselves in our parent
            ptrdiff_t self = findSelfInParent();
            enforce(self >= 0, "Invalid parent widget");

            // Remove ourselves from our current parent
            parent_.children.remove(self);
        }

        // If our new parent is null we'll end early
        if (newParent is null) {
            this.parent_ = null;
            return;
        }

        // Set our parent to our new parent and add ourselves to our new parent's list
        this.parent_ = newParent;
        this.parent_.children ~= this;
    }

    /**
        Update the widget

        Automatically updates all the children first
    */
    void update() {
        
        // Update all our children
        foreach(child; children) {
            child.update();
        }

        // Update ourselves
        this.onUpdate();
    }

    /**
        Draw the widget

        For widget implementing: override onDraw
    */
    final void draw() {

        // Don't draw this widget or its children if we're invisible
        if (!visible) return;

        if (parent_ is null) UI.setScissor(vec4i(0, 0, GameWindow.width, GameWindow.height));

        // Draw ourselves first
        this.onDraw();

        // We set our scissor rectangle to our rendering area
        UI.setScissor(scissorArea);

        // Draw all the children
        foreach(child; children) {
            child.draw();
        }
    }

    /**
        Gets the calculated position of the widget
    */
    final vec2 calculatedPosition() {
        return parent_ !is null ? parent_.calculatedPosition+position : position;
    }

    abstract {

        /**
            Area of the widget
        */
        vec4 area();

        /**
            Area in which the widget cuts out child widgets
        */
        vec4i scissorArea();
    }

    override {

        /**
            Gets this widget as a string

            This returns the tree for this instance of the widget ordered by type name.
        */
        final string toString() const {
            return parent_ is null ? typeName : "%s->%s".format(parent_.toString, typeName);
        }
    }
}