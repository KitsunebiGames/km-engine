# Kitsune Mahjong Engine
Kitsune Mahjong is a game about fox girls playing Mahjong, the game was initially going to be fully open source.
For now the actual gameplay will be closed source.

In this source tree you'll find the engine (and if you look back in the history you'll find a mahjong solitaire game implemented on top.)

## Development/Test Builds

To get access to development builds of Kitsune Mahjong please [support Luna on Patreon](https://www.patreon.com/clipsey).  
You'll get access to a special set of channels for the game; including one where Luna occasionally uploads development builds.

You can discuss the game and see git push logs for the engine and game on Luna's Discord Server
* [English](https://discord.gg/AMpbKAB)
* [日本語](https://discord.gg/Bd3makR)

## Planned Features
This is an non-exhaustive list of planned features we're working on.
Planned features may be subject to change.

 * Riichi Mahjong
   * CPU Opponents
   * Network Play
   * WiFi-Play[1]
   * 3 and 2 player Riichi variants
 * Mahjong Solitaire
 * Various Minigames using Mahjong-like tiles
 * Single Player Story Mode
   * Yuri romcom visual novel with riichi mahjong matches spliced in
 * Multiple supported languages
   * English
   * Japanese

[1] When/if Nintendo Switch port gets completed.  
Development can be followed on the [キツネビ](https://twitter.com/Kitsunebi_Games) Twitter account as well as [Luna's personal twitter](https://twitter.com/Clipsey5)

## Contributing
I will not be accepting any pull-requests for this repository.

## Dependencies
The Kitsune Mahjong engine requires the following dependencies to be present to work:
 * OpenAL Driver ([OpenAL-Soft included on Windows](https://github.com/kcat/openal-soft))
 * OpenGL Driver
 * GLFW3
 * libogg
 * libvorbis
 * libvorbisfile
 * FreeType

On Windows these libraries are copied from the included libs/ folder.

## How to use
Add `km-engine` as a dependency to your project (`dub add km-engine`)

Bootstrap the engine with the following code:
```d
import engine;
void _init() {
    // Initialize your game's resources
    GameWindow.title = "My Game";
}

void _update() {
    // Update and draw your game
}

void _border() {
    // Draw a border if you want to
}

void _postUpdate() {
    // Draw a border if you want to
}

void _cleanup() {
    // Clean up resources when game is requested to close.
}

int main() {
    // Sets the essential game functions
    gameInit = &_init;
    gameUpdate = &_update;
    gameCleanup = &_cleanup;
    gameBorder = &_border;
    gamePostUpdate = &_postUpdate;

    // Handle game initialization, looping and closing the engine after use.
    // It's recommended using a try/catch block to catch any errors that might pop up.
    initEngine();
    startGame(vec2i(1920, 1080)); // The variable is the desired size of the game's frame buffer.
    closeEngine();
    return 0;
}
```