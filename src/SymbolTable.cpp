#include "SymbolTable.h"
#include "Logger.h"
#include <cstdio>
#include <map>

SymbolTable::SymbolTable() : symbolMap() {}


bool SymbolTable::insert(const char* lexeme, int token, int lineNumber, int columnNumber) {
   string key(lexeme);

   if (symbolMap.find(key) != symbolMap.end()) {
      symbolMap[key].occurrences++;
      symbolMap[key].positions.push_back({lineNumber, columnNumber});
      return false;
   }

   symbolMap[key] = {key, token, 1, {{lineNumber, columnNumber}}};

   return true;
}


Symbol* SymbolTable::lookup(const char* lexeme) {
   string key(lexeme);

   auto it = symbolMap.find(key);

   if (it != symbolMap.end()) {
      return &it->second;
   }
   
   return nullptr;
}


void SymbolTable::addConstruct(const char* lexeme, const char* construct) {
   Logger::log("Adding construct " + string(construct) + " to symbol " + string(lexeme));
   Symbol* symbol = lookup(lexeme);
   if (symbol) {
      symbol->construct = string(construct);
   }
}

void SymbolTable::addRelationship(const char* lexeme, const char* relatedLexeme) {
   Logger::log("Adding relationship from " + string(lexeme) + " to " + string(relatedLexeme));
   Symbol* symbol = lookup(lexeme);
   if (symbol) {
      symbol->relationships.push_back(string(relatedLexeme));
   }
}


void SymbolTable::toTSV(const char* filename) {
   FILE* file = fopen(filename, "w");

   if (!file) {
      perror("Failed to open file for writing");
      return;
   }

   fprintf(file, "Lexeme\tToken\tOccurrences\tPositions (line, column)\n");

   for (const auto& pair : symbolMap) {
      const char* token_string = tokenToString(pair.second.token);
      fprintf(file, "%s\t%s\t%d\t", pair.second.lexeme.c_str(), token_string, pair.second.occurrences);

      for (const auto& pos : pair.second.positions) {
         fprintf(file, "(%d,%d)", pos.first, pos.second);
      }
      fprintf(file, "\n");
   }

   fclose(file);
}

/**
 * @brief Count unique constructs by their token types.
 * @return A map where the key is the TokenType and the value is the count.
 */
map<int, int> SymbolTable::getUniqueConstructCounts() {
   map<int, int> counts;

   for (const auto& pair : symbolMap) {
      int tokenType = pair.second.token;
      counts[tokenType]++;
   }

   return counts;
}