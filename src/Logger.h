#ifndef LOGGER_H
#define LOGGER_H

#include <fstream>
#include <string>

class Logger {
public:
    static void init(const std::string& filename);
    static void log(const std::string& message);
    static void close();
private:
    static std::ofstream logFile;
};

#endif
