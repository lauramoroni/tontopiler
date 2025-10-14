#include "SymbolTable.h"
#include <cstdio>

SymbolTable::SymbolTable() : symbolMap() {}


bool SymbolTable::insert(const char* lexeme, int token) {
   string key(lexeme);

   if (symbolMap.find(key) != symbolMap.end()) {
      symbolMap[key].occurrences++;
      return false;
   }

   symbolMap[key] = {key, token, 1};

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

   fprintf(file, "Lexeme\tToken\n");

   for (const auto& pair : symbolMap) {
      const char* token_string = tokenToString(pair.second.token);
      fprintf(file, "%s\t%s\t%d\n", pair.second.lexeme.c_str(), token_string, pair.second.occurrences);
   }

   fclose(file);
}