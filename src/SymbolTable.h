#ifndef SYMBOLTABLE_H
#define SYMBOLTABLE_H

#include <unordered_map>
#include <string>
#include "token.h"

using namespace std;


struct Symbol
{
   string lexeme;
   int token;
};


class SymbolTable {
private:
   unordered_map<string, Symbol> symbolMap;

public:
   SymbolTable();

   bool insert(const char* lexeme, int token);
   Symbol* lookup(const char* lexeme);

   void toCSV(const char* filename);
};

#endif