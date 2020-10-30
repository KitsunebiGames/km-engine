/*
    Input Handling Subsystem

    Copyright © 2020, Luna Nielsen
    Distributed under the 2-Clause BSD License, see LICENSE file.
    
    Authors: Luna Nielsen
*/
module engine.input;
import bindbc.glfw;

public import engine.input.keyboard;
public import engine.input.mouse;

/**
    Initializes input system
*/
void initInput(GLFWwindow* window) {

    // Initialize keyboard
    Keyboard.initialize(window);

    // Initialize mouse
    Mouse.initialize(window);
}

private struct Keybinding {
    Key key;

    bool lstate;
    bool state;
}

class Input {
private static:
    Keybinding*[string] keybindings;

public static:

    /**
        Register a key and a default binding for a keybinding
    */
    void registerKey(string name, Key binding) {
        keybindings[name] = new Keybinding(binding, false, false);
    }

    /**
        Load keybindings from a list of bindings
    */
    void loadBindings(Key[string] bindings) {
        foreach(name, binding; bindings) {
            registerKey(name, binding);
        }
    }

    /**
        Gets the key attached to a keybinding
    */
    Key getKeyFor(string name) {
        return keybindings[name].key;
    }

    /**
        Whether a user pressed the specified binding button
    */
    bool isPressed(string name) {
        return keybindings[name].state && keybindings[name].state != keybindings[name].lstate;
    }

    /**
        Whether a user pressed the specified binding button the last frame
    */
    bool wasPressed(string name) {
        return !keybindings[name].state && keybindings[name].state != keybindings[name].lstate;
    }

    /**
        Whether a user pressed the specified binding button
    */
    bool isDown(string name) {
        return keybindings[name].state;
    }

    /**
        Whether a user pressed the specified binding button
    */
    bool isUp(string name) {
        return !keybindings[name].state;
    }

    /**
        Updates the keybinding states
    */
    void update() {

        // Update keybindings
        foreach(binding; keybindings) {
            binding.lstate = binding.state;
            binding.state = Keyboard.isKeyPressed(binding.key);
        }
    }
}