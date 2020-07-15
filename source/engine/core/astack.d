/*
    Copyright © 2020, Luna Nielsen
    Distributed under the 2-Clause BSD License, see LICENSE file.
    
    Authors: Luna Nielsen
*/
module engine.core.astack;
import std.exception;

/**
    A stack of actions performed in the game
*/
class ActionStack(ActionT) {
private:
    ActionT[] stack;

public:

    /**
        Push an action to the stack
    */
    ActionT push(ActionT item) {
        stack ~= item;
        return stack[$-1];
    }

    /**
        Peek an action from the stack
    */
    ActionT peek(size_t offset = 0) {
        return stack[$-(offset+1)];
    }

    /**
        Pop action(s) from the stack

        Returns the item that was popped
    */
    ActionT pop() {
        enforce(canPop, "Can not pop empty stack, use canPop to check whether something is pop-able");

        // Get the top of the stack, then decrease its size before returning the previous top element
        ActionT top = stack[$-1];
        stack.length--;
        return top;
    }

    /**
        Gets whether the specified amount of actions can be popped
    */
    bool canPop() {
        return stack.length > 0;
    }
}