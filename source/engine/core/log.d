/*
    Copyright © 2020, Luna Nielsen
    Distributed under the 2-Clause BSD License, see LICENSE file.
    
    Authors: Luna Nielsen
*/
module engine.core.log;
import std.stdio;
import std.file;
import std.format;
import core.stdc.stdlib : exit;

__gshared Logger AppLog;

/**
    A logger
*/
class Logger {
private:
    bool logFileOpened = false;
    File logFile;
    string logFileName;

    void writeLogToFile(string text) {
        
        // Open log file if need be
        if (!logFileOpened) this.openLogFile();

        // Write to log
        logFile.writeln(text);
        logFile.flush();
    }

    void openLogFile() {
        this.logFile = File(this.logFileName, "a");
    }

public:
    /**
        Whether to write logs to file

        TODO: implement
    */
    bool logToFile;

    /**
        Creates a new logger
    */
    this(bool logToFile = false, string logFile = "applog.log") {
        this.logToFile = logToFile;
        this.logFileName = logFile;

        if (logToFile) {
            this.openLogFile();
        }
    }

    /**
        Closes the logger and its attachment to the log file
    */
    ~this() {
        if (logFileOpened) logFile.close();
    }

    /**
        Write info log to stdout
    */
    void info(T...)(string sender, string text, T fmt) {
        string logText = "[%s] info: %s".format(sender, text.format(fmt));
        writeln(logText);
        
        if (logToFile) {
            this.writeLogToFile(logText);
        }
    }

    /**
        Write warning log to stdout
    */
    void warn(T...)(string sender, string text, T fmt) {
        string logText = "[%s] warning: %s".format(sender, text.format(fmt));
        writeln(logText);
        
        if (logToFile) {
            this.writeLogToFile(logText);
        }
    }

    /**
        Writes error to stderr
    */
    void error(T...)(string sender, string text, T fmt) {
        string logText = "[%s] error: %s".format(sender, text.format(fmt));
        stderr.writeln(logText);

        if (logToFile) {
            this.writeLogToFile(logText);
        }
    }

    /**
        Writes a fatal error to stderr and quits the application with status -1
    */
    void fatal(T...)(string sender, string text, T fmt) {
        string logText = "[%s] fatal: %s".format(sender, text.format(fmt));
        stderr.writeln(logText);

        if (logToFile) {
            this.writeLogToFile(logText);
        }

        exit(-1);
    }
}