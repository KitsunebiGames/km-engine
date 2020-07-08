import std.stdio;
import engine;

int main(string[] args)
{
	AppLog = new Logger();

	try {
		AppLog.info("Initializing engine...");
		initializeEngine();
		AppLog.info("Engine initialized...");

		AppLog.info("Starting game loop...");
		gameLoop();
		AppLog.info("Game loop ended, good bye :)");
	} catch (Exception ex) {
		AppLog.fatal(ex.msg);
	}

	return 0;
}
