/*
    Copyright © 2020, Luna Nielsen
    Distributed under the 2-Clause BSD License, see LICENSE file.
    
    Authors: Luna Nielsen
*/
import std.stdio;
import engine;
import game;
import core.memory;

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

	// Destroy the app log and collect causing other destructors to also be run
	destroy(AppLog);
	GC.collect();
	return 0;
}
