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
#include <map>

using namespace std;

// Unique inclusion for FlexLexer
#if ! defined(yyFlexLexer)
#   include <FlexLexer.h>
#endif

// External global from lexer.l
extern SymbolTable symbolTable;
extern bool hasError;


// -=-=-=-=- Internal functions prototypes -=-=-=-=-

// Main menu and file browser functions
void browseFiles(string path);
void printMenu(WINDOW* menu_win, int highlight, const vector<string>& choices);
void printFileBrowser(WINDOW* win, int highlight, const vector<string>& files, const string& path);
string getAbsolutePath(string path);

// Analysis menu functions
void showAnalysisMenu(const string& currentPath);
void constructCounter(WINDOW* parent_win);
void consultLexeme(WINDOW* parent_win);
void showTable(WINDOW* parent_win);

// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-==-=-==-=-=-=-=-


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
            if (name == "." || name == "..") continue;
            
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

    WINDOW* win = newwin(LINES, COLS, 0, 0); // Fullscreen window
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
        
        if (parentPath == currentPath) {
            browseFiles(currentPath);
        } else {
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
        showAnalysisMenu(currentPath);
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
        cout << "\nLexical analysis finished with errors.\n";
    } else {
        cout << "\nLexical analysis completed successfully.\n";
        cout << "Exporting symbol table to 'symbol_table.tsv'...\n";
        symbolTable.toTSV("symbol_table.tsv");
    }

    cout << "\nPress [Enter] to continue...";
    cin.clear();
    fflush(stdin);
    cin.get();
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
    
    // Título opcional
    if (choices.size() == 2) { // Menu Principal
        mvwprintw(menu_win, y - 1, x, "--- TONTO COMPILER ---");
    } else { // Menu de Análise
         mvwprintw(menu_win, y - 1, x, "--- ANALYSIS MENU ---");
    }
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


/**
 * @brief Shows the analysis menu after lexical analysis.
 * @param currentPath The current directory path to return to.
 */
void showAnalysisMenu(const string& currentPath) {
    initscr();
    clear();
    noecho();
    cbreak();
    curs_set(0);

    int height = 12;
    int width = 50;
    int starty = (LINES - height) / 2;
    int startx = (COLS - width) / 2;

    WINDOW* menu_win = newwin(height, width, starty, startx);
    keypad(menu_win, TRUE);

    vector<string> choices = {
        "1. Construct Counter", 
        "2. Consult Lexeme", 
        "3. Show Table", 
        "4. Back to File Browser"
    };
    int highlight = 0;
    int choice = -1;

    while (choice != 3) { 
        printMenu(menu_win, highlight, choices);
        int c = wgetch(menu_win);
        switch (c) {
            case KEY_UP:
                if (highlight > 0) highlight--;
                break;
            case KEY_DOWN:
                if (highlight < (int)choices.size() - 1) highlight++;
                break;
            case 'q': // 'q' also goes back to file browser
                choice = 3;
                break;
            case 10: // Enter
                choice = highlight;

                if (choice != 3) {
                    werase(menu_win);
                    wrefresh(menu_win);
                    delwin(menu_win);
                    endwin(); 
                    
                    switch (choice) {
                        case 0:
                            constructCounter(stdscr); 
                            break;
                        case 1:
                            consultLexeme(stdscr);
                            break;
                        case 2:
                            showTable(stdscr);
                            break;
                    }
                    
                    // The subfunction already called endwin(), so we need to re-init ncurses
                    initscr();
                    clear();
                    noecho();
                    cbreak();
                    curs_set(0);
                    menu_win = newwin(height, width, starty, startx);
                    keypad(menu_win, TRUE);

                    choice = -1;
                }
                break;  // Judson, please don't kill me
        }
    }

    if (menu_win) {
        werase(menu_win);
        wrefresh(menu_win);
        delwin(menu_win);
    }
    endwin();

    browseFiles(currentPath);
}


/**
 * @brief Count unique constructs and display them.
 * @param parent_win Ncurses window to draw in.
 */
void constructCounter(WINDOW* parent_win) {
    initscr();
    clear();
    noecho();
    cbreak();
    curs_set(0);
    
    WINDOW* win = newwin(LINES, COLS, 0, 0);
    box(win, 0, 0);
    mvwprintw(win, 1, 2, "--- Construct Counter ---");

    map<int, int> counts = symbolTable.getUniqueConstructCounts();
    int y = 3;
    
    mvwprintw(win, y++, 2, "%-25s | %s", "Token Type", "Occurrences");
    mvwprintw(win, y++, 2, "--------------------------------------");

    for (auto const& [tokenType, count] : counts) {
        if (y >= LINES - 2) {
             mvwprintw(win, y, 2, "Press any key for more...");
             wrefresh(win);
             wgetch(win);
             werase(win);
             box(win, 0, 0);
             mvwprintw(win, 1, 2, "--- Construct Counter (Page 2) ---");
             y = 3;
             mvwprintw(win, y++, 2, "%-25s | %s", "Token Type", "Occurrences");
             mvwprintw(win, y++, 2, "--------------------------------------");
        }
        mvwprintw(win, y++, 2, "%-25s | %d", tokenToString(tokenType), count);
    }

    mvwprintw(win, LINES - 2, 2, "Press any key to return to the menu...");
    wrefresh(win);
    wgetch(win);

    delwin(win);
    endwin();
}

/**
 * @brief Consult a lexeme in the symbol table.
 * @param parent_win Ncurses window to draw in.
 */
void consultLexeme(WINDOW* parent_win) {
    initscr();
    clear();
    echo();
    nocbreak();
    curs_set(1);

    WINDOW* win = newwin(LINES, COLS, 0, 0);
    box(win, 0, 0);
    mvwprintw(win, 1, 2, "--- Consult Lexeme ---");
    mvwprintw(win, 3, 2, "Enter lexeme to consult: ");
    
    char lexeme_str[100];
    wmove(win, 3, 28);
    wrefresh(win);
    
    wgetnstr(win, lexeme_str, 99);

    noecho();
    cbreak();
    curs_set(0);

    Symbol* symbol = symbolTable.lookup(lexeme_str);

    werase(win);
    box(win, 0, 0);
    mvwprintw(win, 1, 2, "--- Consult Lexeme Results ---");

    if (symbol != nullptr) {
        mvwprintw(win, 3, 2, "Lexeme: %s", symbol->lexeme.c_str());
        mvwprintw(win, 4, 2, "Token: %s", tokenToString(symbol->token));
        mvwprintw(win, 5, 2, "Occurrences: %d", symbol->occurrences);
        
        string lines = "Positions (line, column): ";
        for (size_t i = 0; i < symbol->positions.size(); ++i) {
            lines += "(" + to_string(symbol->positions[i].first) + "," + to_string(symbol->positions[i].second) + ")";
            if (i < symbol->positions.size() - 1) {
                lines += ", ";
            }
        }
        mvwprintw(win, 6, 2, "%s", lines.c_str());

    } else {
        mvwprintw(win, 3, 2, "Lexeme '%s' not found.", lexeme_str);
    }

    mvwprintw(win, LINES - 2, 2, "Press any key to return to the menu...");
    wrefresh(win);
    wgetch(win);

    delwin(win);
    endwin();
}


/**
 * @brief Show the symbol table from the TSV file.
 * @param parent_win Ncurses window to draw in.
 */
void showTable(WINDOW* parent_win) {
    initscr();
    clear();
    noecho();
    cbreak();
    curs_set(0);

    WINDOW* win = newwin(LINES, COLS, 0, 0);
    keypad(win, TRUE);  // Enable arrows input
    box(win, 0, 0);
    mvwprintw(win, 1, 2, "--- Symbol Table (symbol_table.tsv) ---");

    // Initialize colors if supported
    bool use_colors = false;
    if (has_colors() && can_change_color()) {
        start_color();
        use_colors = true;
        // Define a few color pairs for columns. Use modulo indexing when more columns exist.
        init_pair(1, COLOR_WHITE, COLOR_BLACK); // Lexeme
        init_pair(2, COLOR_CYAN, COLOR_BLACK);  // Token
        init_pair(3, COLOR_YELLOW, COLOR_BLACK); // Occurrences
        init_pair(4, COLOR_GREEN, COLOR_BLACK); // Line Numbers
        init_pair(5, COLOR_MAGENTA, COLOR_BLACK);
        init_pair(6, COLOR_BLUE, COLOR_BLACK);
    }

    ifstream tsv_file("symbol_table.tsv");
    vector<string> lines;

    if (!tsv_file.is_open()) {
        mvwprintw(win, 3, 2, "Error: Could not open 'symbol_table.tsv'.");
        mvwprintw(win, LINES - 2, 2, "Press any key to return...");
        wrefresh(win);
        wgetch(win);
        delwin(win);
        endwin();
        return;
    }

    // Read all lines into memory so we can provide scrollable navigation
    string lineBuf;
    while (getline(tsv_file, lineBuf)) {
        lines.push_back(lineBuf);
    }
    tsv_file.close();

    // Pre-split and wrap all rows so we can compute heights and render multi-line cells
    int total = (int)lines.size();
    vector<vector<string>> allCols(total);
    for (int i = 0; i < total; ++i) {
        const string& raw = lines[i];
        size_t s = 0;
        while (true) {
            size_t tab = raw.find('\t', s);
            if (tab == string::npos) {
                allCols[i].push_back(raw.substr(s));
                break;
            }
            allCols[i].push_back(raw.substr(s, tab - s));
            s = tab + 1;
        }
    }

    auto wrap_cell = [&](const string& cell, int w, bool lastCol) -> vector<string> {
        vector<string> out;
        if (w < 1) w = 1;
        if (lastCol && cell.find(',') != string::npos) {
            // Wrap by comma-separated tokens to keep numbers intact
            vector<string> tokens;
            size_t p = 0;
            while (true) {
                size_t q = cell.find(',', p);
                if (q == string::npos) {
                    string t = cell.substr(p);
                    // trim leading spaces
                    if (!t.empty() && t[0] == ' ') t.erase(0, 1);
                    tokens.push_back(t);
                    break;
                }
                string t = cell.substr(p, q - p);
                if (!t.empty() && t[0] == ' ') t.erase(0, 1);
                tokens.push_back(t);
                p = q + 1;
            }

            string current;
            for (size_t ti = 0; ti < tokens.size(); ++ti) {
                string tok = tokens[ti];
                string withComma = (ti + 1 < tokens.size()) ? tok + "," : tok;
                if ((int)current.length() == 0) {
                    current = withComma;
                } else if ((int)current.length() + 1 + (int)withComma.length() <= w) {
                    current += " " + withComma;
                } else {
                    out.push_back(current);
                    current = withComma;
                }
            }
            if (!current.empty()) out.push_back(current);
            if (out.empty()) out.push_back("");
            return out;
        }

        // Generic wrap by fixed width
        for (size_t pos = 0; pos < cell.size();) {
            int take = min(w, (int)cell.size() - (int)pos);
            out.push_back(cell.substr(pos, take));
            pos += take;
        }
        if (out.empty()) out.push_back("");
        return out;
    };

    // Precompute wrapped columns and row heights
    vector<vector<vector<string>>> wrapped(total); // wrapped[row][col] -> lines
    vector<int> rowHeights(total, 1);
    for (int i = 0; i < total; ++i) {
        int ncols = max(1, (int)allCols[i].size());
        int available = COLS - 4;
        vector<int> colWidths(ncols, available / ncols);
        colWidths.back() += available % ncols;

        wrapped[i].resize(ncols);
        int maxh = 1;
        for (int j = 0; j < ncols; ++j) {
            int w = max(1, colWidths[j] - 1);
            wrapped[i][j] = wrap_cell(allCols[i][j], w, j == ncols - 1);
            maxh = max(maxh, (int)wrapped[i][j].size());
        }
        rowHeights[i] = maxh;
    }

    // Navigation state
    int offset = 0; // first visible row index
    int cursor = 0; // selected row index
    int visibleHeight = max(1, LINES - 5); // available display lines for rows

    auto visibleSpanFromOffset = [&](int startIdx) {
        int used = 0;
        int idx = startIdx;
        while (idx < total && used + rowHeights[idx] <= visibleHeight) {
            used += rowHeights[idx];
            ++idx;
        }
        return make_pair(used, idx - 1); // used lines and last fully visible row index
    };

    auto ensureCursorVisible = [&]() {
        if (cursor < offset) {
            offset = cursor;
            return;
        }
        int used = 0;
        for (int i = offset; i <= cursor; ++i) used += rowHeights[i];
        while (used > visibleHeight) {
            used -= rowHeights[offset];
            offset++;
        }
    };

    keypad(win, TRUE);
    int ch;
    bool done = false;
    while (!done) {
        werase(win);
        box(win, 0, 0);
        mvwprintw(win, 1, 2, "--- Symbol Table (symbol_table.tsv) ---");

        // Render rows starting at offset until we run out of space
        int yline = 3;
        for (int idx = offset; idx < total; ++idx) {
            if (yline > LINES - 3) break;
            int h = rowHeights[idx];
            if (yline + h - 1 > LINES - 3) break; // won't fit

            int ncols = max(1, (int)wrapped[idx].size());
            int available = COLS - 4;
            vector<int> colWidths(ncols, available / ncols);
            colWidths.back() += available % ncols;

            for (int sub = 0; sub < h; ++sub) {
                int x = 2;
                bool highlight = (idx == cursor);
                for (int j = 0; j < ncols; ++j) {
                    string cellPart = "";
                    if (sub < (int)wrapped[idx][j].size()) cellPart = wrapped[idx][j][sub];
                    // truncate if needed (defensive)
                    if ((int)cellPart.length() > colWidths[j] - 1) {
                        if (colWidths[j] > 4)
                            cellPart = cellPart.substr(0, colWidths[j] - 4) + "...";
                        else
                            cellPart = cellPart.substr(0, max(0, colWidths[j] - 1));
                    }

                    if (use_colors) {
                        int pair = (j % 6) + 1;
                        wattron(win, COLOR_PAIR(pair));
                        if (highlight) wattron(win, A_REVERSE);
                        mvwprintw(win, yline + sub, x, "%s", cellPart.c_str());
                        if (highlight) wattroff(win, A_REVERSE);
                        wattroff(win, COLOR_PAIR(pair));
                    } else {
                        if (highlight) wattron(win, A_REVERSE);
                        mvwprintw(win, yline + sub, x, "%s", cellPart.c_str());
                        if (highlight) wattroff(win, A_REVERSE);
                    }

                    x += colWidths[j];
                    if (x < COLS - 2) mvwprintw(win, yline + sub, x - 1, " ");
                }
            }

            yline += h;
        }

        mvwprintw(win, LINES - 2, 2, "Arrows: navigate  PgUp/PgDn: jump  q: quit    Row %d/%d", cursor + 1, total);
        wrefresh(win);

        ch = wgetch(win);
        switch (ch) {
            case 'q':
            case 27:
                done = true; break;
            case KEY_DOWN:
                if (cursor < total - 1) {
                    cursor++;
                    ensureCursorVisible();
                }
                break;
            case KEY_UP:
                if (cursor > 0) {
                    cursor--;
                    ensureCursorVisible();
                }
                break;
            case KEY_NPAGE:
                // Jump forward by visibleHeight in terms of display lines: advance offset until we've skipped visibleHeight lines
                {
                    int seen = 0;
                    int i = offset;
                    while (i < total && seen + rowHeights[i] <= visibleHeight) { seen += rowHeights[i]; ++i; }
                    if (i < total) {
                        offset = i;
                        cursor = min(cursor + (i - offset), total - 1);
                    } else {
                        // go to last page
                        int back = total - 1;
                        // move offset so last rows fit
                        int used = 0;
                        int j = total - 1;
                        while (j >= 0 && used + rowHeights[j] <= visibleHeight) { used += rowHeights[j]; --j; }
                        offset = j + 1;
                        cursor = min(cursor + visibleHeight, total - 1);
                    }
                }
                ensureCursorVisible();
                break;
            case KEY_PPAGE:
                // Jump backward by visibleHeight in terms of display lines
                {
                    if (offset == 0) break;
                    int used = 0;
                    int j = offset - 1;
                    while (j >= 0 && used + rowHeights[j] <= visibleHeight) { used += rowHeights[j]; --j; }
                    offset = max(0, j + 1);
                    cursor = max(0, cursor - visibleHeight);
                }
                ensureCursorVisible();
                break;
            default:
                break;
        }
    }

    delwin(win);
    endwin();
}