#ifndef TUI_H
#define TUI_H

#include <string>

/**
 * @brief Main function for Terminal User Interface (TUI).
 * Presents the main menu.
 */
void startTUI();

/**
 * @brief Function that runs the lexer on the selected file.
 * @param filePath The full path to the .tonto file to be analyzed.
 */
void runLexer(const char* filePath);

#endif