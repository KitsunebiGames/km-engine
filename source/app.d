/*
    Copyright © 2020, Luna Nielsen
    Distributed under the 2-Clause BSD License, see LICENSE file.
    
    Authors: Luna Nielsen
*/
import std.stdio;
import engine;
import game;

int main(string[] args)
{
	AppLog = new Logger();

	try {
		AppLog.info("AppMain", "Initializing engine...");
		initEngine();
		AppLog.info("AppMain", "Engine initialized...");

		AppLog.info("AppMain", "Starting game loop...");
		initGame();
		gameLoop();
		AppLog.info("AppMain", "Game loop ended, good bye :)");
	} catch (Exception ex) {
		AppLog.fatal("AppMain", ex.msg);
	}

	return 0;
}
