#include "SymbolTable.h"
#include <unordered_map>
#include <string>

using namespace std;

class SymbolTable {
   private:
   unordered_map<string, Symbol> symbolMap;

   public:
   bool insert(const char* lexeme, int token) {
      string key(lexeme);

      if (symbolMap.find(key) != symbolMap.end()) {
         return false;
      }

      symbolMap[key] = {lexeme, token};

      return true;
   }
   
   Symbol* lookup(const char* lexeme) {
      string key(lexeme);

      auto it = symbolMap.find(key);

      if (it != symbolMap.end()) {
         return &it->second;
      }
      
      return nullptr;
   }

};
