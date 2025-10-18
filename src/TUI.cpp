#include "TUI.h"
#include "SymbolTable.h"
#include "token.h"

#include <ncurses.h>
#include <menu.h>
#include <iostream>
#include <fstream>
#include <vector>
#include <string>
#include <dirent.h>
#include <sys/stat.h>
#include <unistd.h>
#include <limits.h>

using namespace std;

// Unique inclusion for FlexLexer
#if ! defined(yyFlexLexer)
#   include <FlexLexer.h>
#endif

// External global from lexer.l
extern SymbolTable symbolTable;
extern bool hasError;


void browseFiles(string path);
void printMenu(WINDOW* menu_win, int highlight, const vector<string>& choices);
void printFileBrowser(WINDOW* win, int highlight, const vector<string>& files, const string& path);
string getAbsolutePath(string path);


void startTUI() {
    // Init and configure ncurses
    initscr();
    clear();
    noecho();
    cbreak();
    curs_set(0); // Hide cursor

    // Menu window settings
    int height = 10;
    int width = 40;
    int starty = (LINES - height) / 2; // Center vertically
    int startx = (COLS - width) / 2; // Center horizontally

    WINDOW* menu_win = newwin(height, width, starty, startx);
    keypad(menu_win, TRUE); // Enable arrow keys

    vector<string> choices = {"Lexical Analysis", "Quit"};
    int highlight = 0;
    int choice = -1;

    // Main menu loop
    while (choice == -1) {
        printMenu(menu_win, highlight, choices);
        int c = wgetch(menu_win); // Wait for a key press
        switch (c) {
            case KEY_UP:
                if (highlight > 0) highlight--;
                break;
            case KEY_DOWN:
                if (highlight < (int)choices.size() - 1) highlight++;
                break;
            case 10: // Enter key
                choice = highlight;
                break;
            case 'q': // Quit with 'q'
                choice = 1; 
                break;
        }
    }

    // Clear the window and exit ncurses
    werase(menu_win);
    wrefresh(menu_win);
    delwin(menu_win);
    endwin(); 

    if (choice == 0) {
        // Start the file browser in the current directory of the executable
        char cwd[PATH_MAX];
        if (getcwd(cwd, sizeof(cwd)) != NULL) {
            browseFiles(string(cwd));
        } else {
            perror("getcwd() error");
            browseFiles("."); // Fallback to relative directory
        }
    }
}


/**
 * @brief Get absolute path from a given path.
 * @param path The input path (relative or absolute).
 * @return The absolute path as a string.
 */
string getAbsolutePath(string path) {
    char resolved_path[PATH_MAX];
    if (realpath(path.c_str(), resolved_path)) {
        return string(resolved_path);
    }
    return path;
}

/**
 * @brief Opens the file browser interface.
 * @param path The starting directory path.
 */
void browseFiles(string path) {
    DIR *dir;
    struct dirent *entry;
    vector<string> files;
    
    string currentPath = getAbsolutePath(path);

    if ((dir = opendir(currentPath.c_str())) != NULL) {
        files.push_back("../");
        
        // Read directory entries
        while ((entry = readdir(dir)) != NULL) {
            string name = entry->d_name;
            if (name == "." || name == "..") continue; // Pula . e ..
            
            string full_path = currentPath + "/" + name;
            struct stat st;
            if (stat(full_path.c_str(), &st) == 0) {
                if (S_ISDIR(st.st_mode)) {
                    files.push_back(name + "/");
                } else if (name.size() > 6 && name.substr(name.size() - 6) == ".tonto") {
                    files.push_back(name); // Add only .tonto files
                }
            }
        }
        closedir(dir);
    } else {
        // Failed to open directory (e.g., permission denied)
        endwin(); // Exit ncurses if it fails
        cerr << "Error: Could not open directory " << currentPath << endl;
        return;
    }

    // Re-initialize ncurses for the file browser
    initscr();
    clear();
    noecho();
    cbreak();
    curs_set(0);

    WINDOW* win = newwin(LINES, COLS, 0, 0); // Janela de tela cheia
    keypad(win, TRUE);
    
    int highlight = 0;
    int choice = -1;
    
    // browser loop
    while(choice == -1) {
        printFileBrowser(win, highlight, files, currentPath);
        int c = wgetch(win);
        switch(c) {
            case KEY_UP:
                if(highlight > 0) highlight--;
                break;
            case KEY_DOWN:
                if(highlight < (int)files.size() - 1) highlight++;
                break;
            case 10: // Enter
                choice = highlight;
                break;
            case 'q':
                choice = -2;
                break;
        }
    }

    // Save the selected file/directory
    string selected = (choice >= 0) ? files[choice] : "";

    // Clear and close the ncurses window
    werase(win);
    wrefresh(win);
    delwin(win);
    endwin();

    // If chose to quit
    if (choice == -2) {
        return; 
    }

    // If selected an item (choice >= 0)
    string new_path = currentPath + "/" + selected;

    // If selected "../" (choice == 0)
    if (choice == 0) {
        string parentPath = getAbsolutePath(new_path);
        
        // CORREÇÃO (Raiz): Se o caminho pai for o mesmo (já estamos na raiz),
        // recarrega o navegador no diretório atual.
        if (parentPath == currentPath) {
            browseFiles(currentPath);
        } else {
            // Se for diferente, navega para o pai
            browseFiles(parentPath);
        }
        return;
    }

    // If selected another item (file or directory)
    struct stat st;
    if (stat(new_path.c_str(), &st) != 0) {
         // If there is an error getting stat (e.g., broken link), reload
        browseFiles(currentPath);
        return;
    }
   
    if (S_ISDIR(st.st_mode)) {
        // If it's a directory, navigate into it
        browseFiles(new_path);
    } else {
        // If it's a file (.tonto), run the lexer
        runLexer(new_path.c_str());

        cout << "\nAnalysis complete. Press [Enter] to return to the browser...";
        cin.clear();
        fflush(stdin);
        cin.get();
        
        browseFiles(currentPath);
    }
}


/**
 * @brief Executes the lexer on the specified file.
 * @param filePath The full path to the .tonto file to be analyzed.
 */
void runLexer(const char* filePath) {
    ifstream fin(filePath);
    if (!fin.is_open()) {
        cerr << "Error: Could not open file '" << filePath << "'\n";
        return;
    }

    cout << "-=-=-=- Lexical Analysis -=-=-=-\n";
    cout << "Analysing file: " << filePath << "\n\n";
    
    yyFlexLexer lexer;
    lexer.switch_streams(&fin, nullptr);

    symbolTable = SymbolTable();
    hasError = false;
    
    lexer.yylex();  // Call lex
    
    fin.close();

    if (hasError) {
        cout << "\nAnálise Léxica finalizada com erros.\n";
    } else {
        cout << "\nAnálise Léxica finalizada sem erros.\n";
        cout << "Exportando Tabela de Símbolos para 'symbol_table.tsv'...\n";
        symbolTable.toTSV("symbol_table.tsv");
    }
}


/**
 * @brief Draw the main menu.
 * @param menu_win The window to draw the menu in.
 * @param highlight The currently highlighted menu item index.
 * @param choices The list of menu choices.
 */
void printMenu(WINDOW* menu_win, int highlight, const vector<string>& choices) {
    int x = 2, y = 2;
    werase(menu_win); // Clear the window
    box(menu_win, 0, 0); // Draw the border
    mvwprintw(menu_win, y - 1, x, "--- TONTO COMPILER ---");
    y++; // Move down a line

    for (int i = 0; i < (int)choices.size(); i++) {
        if (highlight == i) {
            wattron(menu_win, A_REVERSE); // Highlight the selection
            mvwprintw(menu_win, y, x, "%s", choices[i].c_str());
            wattroff(menu_win, A_REVERSE); // Remove highlight
        } else {
            mvwprintw(menu_win, y, x, "%s", choices[i].c_str());
        }
        y++;
    }
    wrefresh(menu_win); // Refresh the screen
}

/**
 * @brief Draw the file browser.
 * @param win The window to draw the file browser in.
 * @param highlight The currently highlighted file index.
 * @param files The list of files/directories to display.
 * @param path The current directory path.
 */
void printFileBrowser(WINDOW* win, int highlight, const vector<string>& files, const string& path) {
    werase(win);
    box(win, 0, 0);
    
    // Print header
    mvwprintw(win, 1, 2, "Current dir: %s (Press 'q' to quit)", path.c_str());
    mvwprintw(win, 2, 2, "-------------------------------------------------");
    
    int max_lines = LINES - 5;
    int offset = 0;

    // Scroll logic if the list is larger than the screen
    if (highlight >= max_lines) {
        offset = highlight - max_lines + 1;
    }

    // Print the list of files
    for(int i = offset; i < (int)files.size(); ++i) {
        int current_line = i - offset + 3; // Line to print on the screen
        if (current_line > LINES - 3) break; // Don't draw beyond the border

        if(highlight == i) {
            wattron(win, A_REVERSE);
            mvwprintw(win, current_line, 2, "%s", files[i].c_str());
            wattroff(win, A_REVERSE);
        } else {
            mvwprintw(win, current_line, 2, "%s", files[i].c_str());
        }
    }
    wrefresh(win);
}