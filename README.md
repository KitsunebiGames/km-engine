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

[1] When/if Nintendo Switch port gets completed.

## Contributing
I will not be accepting any pull-requests for this repository.

## Dependencies
Kitsune Mahjong requires the following dependencies to be present to work:
 * OpenAL Driver ([OpenAL-Soft included on Windows](https://github.com/kcat/openal-soft))
 * OpenGL Driver
 * GLFW3
 * libogg
 * libvorbis
 * libvorbisfile
 * FreeType

On Windows these libraries are copied from the included libs/ folder.