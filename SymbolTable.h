#include <unordered_map>
#include <string>

using namespace std;


struct Symbol
{
   const char* lexeme;
   int token;
};


class SymbolTable {
private:
   unordered_map<string, Symbol> symbolMap;

public:
   SymbolTable();

   bool insert(const char* lexeme, int token);
   Symbol* lookup(const char* lexeme);
};
