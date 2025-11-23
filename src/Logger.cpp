#include "Logger.h"
#include <iostream>

std::ofstream Logger::logFile;

void Logger::init(const std::string& filename) {
    if (logFile.is_open()) {
        logFile.close();
    }
    logFile.open(filename, std::ios::out | std::ios::trunc);
}

void Logger::log(const std::string& message) {
    if (logFile.is_open()) {
        logFile << message << std::endl;
        logFile.flush();
    }
}

void Logger::close() {
    if (logFile.is_open()) {
        logFile.close();
    }
}
