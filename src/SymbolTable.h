#ifndef SYMBOLTABLE_H
#define SYMBOLTABLE_H

#include <unordered_map>
#include <string>
#include <vector>
#include <map>
#include "token.h"

using namespace std;


struct Symbol
{
   string lexeme;
   int token;
   int occurrences;
   vector<int> lineNumbers;
};


class SymbolTable {
private:
   unordered_map<string, Symbol> symbolMap;

public:
   SymbolTable();

   bool insert(const char* lexeme, int token, int lineNumber);
   Symbol* lookup(const char* lexeme);

   void toTSV(const char* filename);

   map<int, int> getUniqueConstructCounts();
};

#endif