# Kitsune Mahjong Engine
Kitsune Mahjong is a game about fox girls playing Mahjong, the game was initially going to be fully open source.
For now the actual gameplay will be closed source.

In this source tree you'll find the engine (and if you look back in the history you'll find a mahjong solitaire game implemented on top.)

## Development/Test Builds

You can find Development builds on Luna's Discord server.
* [English](https://discord.gg/AMpbKAB)
* [日本語](https://discord.gg/Bd3makR)

## Contributing
I will not be accepting any pull-requests for this repository.

## Dependencies
Kitsune Mahjong requires the following dependencies to be present to work:
 * OpenAL Driver (or openal-soft)
 * OpenGL Driver
 * GLFW3
 * libogg
 * libvorbis
 * libvorbisfile
 * FreeType

## Debugging
To debug the game run
```
dub
```

## Building
To build a release build of the game run
```
dub build --build=release --compiler=ldc2
```
`--compiler=ldc2` is optional, but recommended for performance.

## Licensing
The source code is under the BSD 2-clause license and may be distributed freely as source and binary format.

Game assets are copyrighted to this project's maintainers and/or is licensed for use in this project (Kitsune Mahjong).
* You are **not** allowed to redistribute the game assets without express permission from the creator(s) - unless the license for the asset allows you to do so.

You will not be able to use this code without obtaining the game assets from an official distribution

## June the Fox
![June the Fox](/june.png)

June is this project's mascot and shows in various places in the user interface.

June was designed by [Amasenutiko](https://www.deviantart.com/amasenutiko)