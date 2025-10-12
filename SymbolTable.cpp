#include "SymbolTable.h"


SymbolTable::SymbolTable() : symbolMap() {}


bool SymbolTable::insert(const char* lexeme, int token) {
   string key(lexeme);

   if (symbolMap.find(key) != symbolMap.end()) {
      return false;
   }

   symbolMap[key] = {lexeme, token};

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
