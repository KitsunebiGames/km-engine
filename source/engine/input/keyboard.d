module engine.input.keyboard;
import engine.input;
import bindbc.glfw;
import events;

/**
    Keys
*/
enum Key {
    KeyUnknown = GLFW_KEY_UNKNOWN,
    KeySpace = GLFW_KEY_SPACE,
    KeyApostrophe = GLFW_KEY_APOSTROPHE,
    KeyComma = GLFW_KEY_COMMA,
    KeyMinus = GLFW_KEY_MINUS,
    KeyPeriod = GLFW_KEY_PERIOD,
    KeySlash = GLFW_KEY_SLASH,
    Key0 = GLFW_KEY_0,
    Key1 = GLFW_KEY_1,
    Key2 = GLFW_KEY_2,
    Key3 = GLFW_KEY_3,
    Key4 = GLFW_KEY_4,
    Key5 = GLFW_KEY_5,
    Key6 = GLFW_KEY_6,
    Key7 = GLFW_KEY_7,
    Key8 = GLFW_KEY_8,
    Key9 = GLFW_KEY_9,
    KeySemicolon = GLFW_KEY_SEMICOLON,
    KeyEqual = GLFW_KEY_EQUAL,
    KeyA = GLFW_KEY_A,
    KeyB = GLFW_KEY_B,
    KeyC = GLFW_KEY_C,
    KeyD = GLFW_KEY_D,
    KeyE = GLFW_KEY_E,
    KeyF = GLFW_KEY_F,
    KeyG = GLFW_KEY_G,
    KeyH = GLFW_KEY_H,
    KeyI = GLFW_KEY_I,
    KeyJ = GLFW_KEY_J,
    KeyK = GLFW_KEY_K,
    KeyL = GLFW_KEY_L,
    KeyM = GLFW_KEY_M,
    KeyN = GLFW_KEY_N,
    KeyO = GLFW_KEY_O,
    KeyP = GLFW_KEY_P,
    KeyQ = GLFW_KEY_Q,
    KeyR = GLFW_KEY_R,
    KeyS = GLFW_KEY_S,
    KeyT = GLFW_KEY_T,
    KeyU = GLFW_KEY_U,
    KeyV = GLFW_KEY_V,
    KeyW = GLFW_KEY_W,
    KeyX = GLFW_KEY_X,
    KeyY = GLFW_KEY_Y,
    KeyZ = GLFW_KEY_Z,
    KeyBracket = GLFW_KEY_LEFT_BRACKET,
    KeyBackslash = GLFW_KEY_BACKSLASH,
    KeyRightBracket = GLFW_KEY_RIGHT_BRACKET,
    KeyAccent = GLFW_KEY_GRAVE_ACCENT,
    KeyWorld1 = GLFW_KEY_WORLD_1,
    KeyWorld2 = GLFW_KEY_WORLD_2,

    KeyEscape = GLFW_KEY_ESCAPE,
    KeyEnter = GLFW_KEY_ENTER,
    KeyTab = GLFW_KEY_TAB,
    KeyBackspace = GLFW_KEY_BACKSPACE,
    KeyInsert = GLFW_KEY_INSERT,
    KeyDelete = GLFW_KEY_DELETE,
    KeyRight = GLFW_KEY_RIGHT,
    KeyLeft = GLFW_KEY_LEFT,
    KeyDown = GLFW_KEY_DOWN,
    KeyUp = GLFW_KEY_UP,
    KeyPageUp = GLFW_KEY_PAGE_UP,
    KeyPageDown = GLFW_KEY_PAGE_DOWN,
    KeyHome = GLFW_KEY_HOME,
    KeyEnd = GLFW_KEY_END,
    KeyCapsLock = GLFW_KEY_CAPS_LOCK,
    KeyScrollLock = GLFW_KEY_SCROLL_LOCK,
    KeyNumLock = GLFW_KEY_NUM_LOCK,
    KeyPrintScreen = GLFW_KEY_PRINT_SCREEN,
    KeyPause = GLFW_KEY_PAUSE,
    KeyF1 = GLFW_KEY_F1,
    KeyF2 = GLFW_KEY_F2,
    KeyF3 = GLFW_KEY_F3,
    KeyF4 = GLFW_KEY_F4,
    KeyF5 = GLFW_KEY_F5,
    KeyF6 = GLFW_KEY_F6,
    KeyF7 = GLFW_KEY_F7,
    KeyF8 = GLFW_KEY_F8,
    KeyF9 = GLFW_KEY_F9,
    KeyF10 = GLFW_KEY_F10,
    KeyF11 = GLFW_KEY_F11,
    KeyF12 = GLFW_KEY_F12,
    KeyF13 = GLFW_KEY_F13,
    KeyF14 = GLFW_KEY_F14,
    KeyF15 = GLFW_KEY_F15,
    KeyF16 = GLFW_KEY_F16,
    KeyF17 = GLFW_KEY_F17,
    KeyF18 = GLFW_KEY_F18,
    KeyF19 = GLFW_KEY_F19,
    KeyF20 = GLFW_KEY_F20,
    KeyF21 = GLFW_KEY_F21,
    KeyF22 = GLFW_KEY_F22,
    KeyF23 = GLFW_KEY_F23,
    KeyF24 = GLFW_KEY_F24,
    KeyF25 = GLFW_KEY_F25,
    Keypad0 = GLFW_KEY_KP_0,
    Keypad1 = GLFW_KEY_KP_1,
    Keypad2 = GLFW_KEY_KP_2,
    Keypad3 = GLFW_KEY_KP_3,
    Keypad4 = GLFW_KEY_KP_4,
    Keypad5 = GLFW_KEY_KP_5,
    Keypad6 = GLFW_KEY_KP_6,
    Keypad7 = GLFW_KEY_KP_7,
    Keypad8 = GLFW_KEY_KP_8,
    Keypad9 = GLFW_KEY_KP_9,
    KeypadDecimal = GLFW_KEY_KP_DECIMAL,
    KeypadDivide = GLFW_KEY_KP_DIVIDE,
    KeypadMultiply = GLFW_KEY_KP_MULTIPLY,
    KeypadSubtract = GLFW_KEY_KP_SUBTRACT,
    KeypadAdd = GLFW_KEY_KP_ADD,
    KeypadEnter = GLFW_KEY_KP_ENTER,
    KeypadEqual = GLFW_KEY_KP_EQUAL,
    KeyLeftShift = GLFW_KEY_LEFT_SHIFT,
    KeyLeftControl = GLFW_KEY_LEFT_CONTROL,
    KeyLeftAlt = GLFW_KEY_LEFT_ALT,
    KeyLeftSuper = GLFW_KEY_LEFT_SUPER,
    KeyRightShift = GLFW_KEY_RIGHT_SHIFT,
    KeyRightControl = GLFW_KEY_RIGHT_CONTROL,
    KeyRightAlt = GLFW_KEY_RIGHT_ALT,
    KeyRightSuper = GLFW_KEY_RIGHT_SUPER,
    KeyMenu = GLFW_KEY_MENU,
    KeyLast = GLFW_KEY_LAST,

    KeyEsc = GLFW_KEY_ESC,
    KeyDel = GLFW_KEY_DEL,
    KeyPgUp = GLFW_KEY_PAGEUP,
    KeyPgDown = GLFW_KEY_PAGEDOWN,
    KeypadNumLock = GLFW_KEY_KP_NUM_LOCK,
    KeyLCtrl = GLFW_KEY_LCTRL,
    KeyLShift = GLFW_KEY_LSHIFT,
    KeyLAlt = GLFW_KEY_LALT,
    KeyLSuper = GLFW_KEY_LSUPER,
    KeyRCtrl = GLFW_KEY_RCTRL,
    KeyRShift = GLFW_KEY_RSHIFT,
    KeyRAlt = GLFW_KEY_RALT,
    KeyRSuper = GLFW_KEY_RSUPER,
}

/**
    Keyboard
*/
class Keyboard {
private static:
    GLFWwindow* window;
    dchar curChar;

    bool capsLock;
    bool numLock;

public static:

    /**
        Event that is called every time a new text character is typed
    */
    Event!dchar onKeyboardType;

    /**
        Event that is called every time a new ket event is emitted
    */
    Event!Key onKeyEvent;

    /**
        Constructs the underlying data needed
    */
    void initialize(GLFWwindow* window) {
        this.window = window;

        // Create events
        onKeyboardType = new Event!dchar();
        onKeyEvent = new Event!Key();

        // Do GLFW stuff
        glfwSetInputMode(window, GLFW_LOCK_KEY_MODS, GLFW_TRUE);
        glfwSetCharCallback(window, &onCharCallback);
        glfwSetKeyCallback(window, &onKeyCallback);
    }

    /**
        Gets the current typed text character for text input
    */
    dchar getCurrentCharacter() {
        return curChar;
    }

    /**
        Gets whether a key is pressed
    */
    bool isKeyPressed(Key key) {
        return glfwGetKey(window, key) == GLFW_PRESS;
    }

    /**
        Gets whether a key is pressed
    */
    bool isKeyReleased(Key key) {
        return glfwGetKey(window, key) == GLFW_RELEASE;
    }

    /**
        Gets whether CapsLock is on
    */
    bool isCapsLockOn() {
        return capsLock;
    }

    /**
        Gets whether NumLock is on
    */
    bool isNumLockOn() {
        return numLock;
    }
}

private:
void onKeyEventHandler(Key key) {
    Keyboard.onKeyEvent(null, key);
}

void onCharEventHandler(dchar key) {
    Keyboard.onKeyboardType(null, key);
}

private nothrow extern(C):
void onKeyCallback(GLFWwindow* window, int key, int scancode, int action, int mods) {
    Keyboard.numLock = (mods & GLFW_MOD_NUM_LOCK) > 0;
    Keyboard.capsLock = (mods & GLFW_MOD_CAPS_LOCK) > 0;

    // Cursed magic to make our exception throwing D event handler be callable from this C function
    (cast(void function(Key) nothrow)&onKeyEventHandler)(cast(Key)key);
}

private void onCharCallback(GLFWwindow* window, uint codepoint) {
    Keyboard.curChar = cast(dchar)codepoint;

    // Cursed magic to make our exception throwing D event handler be callable from this C function
    (cast(void function(dchar) nothrow)&onCharEventHandler)(cast(dchar)codepoint);
}
