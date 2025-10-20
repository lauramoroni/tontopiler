#include "SymbolTable.h"
#include <cstdio>
#include <map>

SymbolTable::SymbolTable() : symbolMap() {}


bool SymbolTable::insert(const char* lexeme, int token, int lineNumber) {
   string key(lexeme);

   if (symbolMap.find(key) != symbolMap.end()) {
      symbolMap[key].occurrences++;
      symbolMap[key].lineNumbers.push_back(lineNumber);
      return false;
   }

   symbolMap[key] = {key, token, 1, {lineNumber}};

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


void SymbolTable::toTSV(const char* filename) {
   FILE* file = fopen(filename, "w");

   if (!file) {
      perror("Failed to open file for writing");
      return;
   }

   fprintf(file, "Lexeme\tToken\tOccurrences\tLineNumbers\n");

   for (const auto& pair : symbolMap) {
      const char* token_string = tokenToString(pair.second.token);
      fprintf(file, "%s\t%s\t%d\t", pair.second.lexeme.c_str(), token_string, pair.second.occurrences);

      for (size_t i = 0; i < pair.second.lineNumbers.size(); ++i) {
         int lineNumber = pair.second.lineNumbers[i];
         fprintf(file, "%d", lineNumber);
         if (i + 1 < pair.second.lineNumbers.size()) {
            fprintf(file, ",");
         }
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