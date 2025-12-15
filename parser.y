%{
#include "TUI.h"
#include "Logger.h"
#include "SymbolTable.h"
#include <cstring>
#include <string>
#include <iostream>

extern SymbolTable symbolTable;
extern int getLineNo();
extern std::string getSyntaxErrorMsg(); 

int yylex(void);
int yyparse(void);
void yyerror(const char *s);
extern int errorType;
%}

%code requires {
#include <vector>
#include <string>
}

%union {
    char* str;
    std::vector<std::string>* list;
}

%define parse.error verbose

%token <str> NUM
%token <str> ESTEREOTIPO_CLASSES
%token <str> ESTEREOTIPO_RELACOES
%token <str> RESERVADAS
%token <str> PACKAGE
%token <str> IMPORT
%token <str> GENSETS
%token <str> SIMBOLOS
%token <str> CONVENCAO_IDENTIFICADOR
%token <str> CONVENCAO_RELACOES
%token <str> CONVENCAO_INSTANCIAS
%token <str> TIPOS_NATIVOS
%token <str> NOVOS_TIPOS
%token <str> META_ATRIBUTOS
%token <str> ENUM
%token <str> TOKEN_DESCONHECIDO

%type <list> relacao_classe_itens
%type <list> enum_itens
%type <list> relacoes_escopo
%type <list> generalizacao_itens


%%
ontology: 
      | package_declaration ontology_body { Logger::log("Reduced: ontology with package"); }

ontology_body:
      | element { Logger::log("Reduced: ontology_body -> element"); }
      | element ontology_body { Logger::log("Reduced: ontology_body -> element ontology_body"); }

package_declaration: 
      | PACKAGE CONVENCAO_IDENTIFICADOR { symbolTable.addConstruct($2, "Package"); Logger::log("Reduced: package_declaration"); }
      | IMPORT CONVENCAO_IDENTIFICADOR { symbolTable.addConstruct($2, "Import"); Logger::log("Reduced: package_declaration (import)");}

element:
      | package_declaration { Logger::log("Reduced: element -> package_declaration"); }
      | classe { Logger::log("Reduced: element -> classe"); }
      | relacao_classe { Logger::log("Reduced: element -> relacao_classe"); }
      | data_types { Logger::log("Reduced: element -> data_types"); }
      | enumerations { Logger::log("Reduced: element -> enumerations"); }
      | generalizacoes { Logger::log("Reduced: element -> generalizacoes"); }
      | declaracao_relacoes { Logger::log("Reduced: element -> declaracao_relacoes"); }

classe:
      | ESTEREOTIPO_CLASSES CONVENCAO_IDENTIFICADOR { symbolTable.addConstruct($2, $1); Logger::log("Reduced: classe (simple)"); }
      | ESTEREOTIPO_CLASSES CONVENCAO_IDENTIFICADOR '{' atributos '}' { symbolTable.addConstruct($2, $1); Logger::log("Reduced: classe (with attributes)"); }
      | ESTEREOTIPO_CLASSES CONVENCAO_IDENTIFICADOR '{' error '}' { 
            Logger::log("Recuperado de erro dentro da classe."); 
            yyerrok; 
      }

atributos:
      | atributo
      | atributo atributos

atributo:
      | CONVENCAO_RELACOES ':' TIPOS_NATIVOS { Logger::log("Reduced: atributo (native)"); }
      | CONVENCAO_RELACOES ':' NOVOS_TIPOS { Logger::log("Reduced: atributo (custom)"); }
      | CONVENCAO_RELACOES ':' TIPOS_NATIVOS cardinalidade { Logger::log("Reduced: atributo (native with cardinality)"); }
      | CONVENCAO_RELACOES ':' NOVOS_TIPOS cardinalidade { Logger::log("Reduced: atributo (custom with cardinality)"); }
      | CONVENCAO_RELACOES ':' TIPOS_NATIVOS '{' META_ATRIBUTOS '}' { Logger::log("Reduced: atributo (native with meta)"); }
      | CONVENCAO_RELACOES ':' NOVOS_TIPOS '{' META_ATRIBUTOS '}' { Logger::log("Reduced: atributo (custom with meta)"); }

relacao_classe:
      | ESTEREOTIPO_CLASSES CONVENCAO_IDENTIFICADOR ESTEREOTIPO_RELACOES relacao_classe_itens { 
          symbolTable.addConstruct($2, "RelacaoClasse");
          for (const auto& rel : *$4) {
                  symbolTable.addRelationship($2, (string($3) + string(":") + rel).c_str());
          }
          delete $4;
          Logger::log("Reduced: relacao_classe"); 
      }

relacao_classe_itens:
      | CONVENCAO_IDENTIFICADOR { 
            Symbol* symbol = symbolTable.lookup($1);

            int currentUseLine = symbol ? symbol->positions.back().first : 0;
            
            Logger::log("Symbol '" + std::string($1) + "' construct: " + (symbol ? symbol->construct : "(not found)"));
            Logger::log("Symbol '" + std::string($1) + "' current use line: " + std::to_string(currentUseLine));
            
            if (!symbol || symbol->construct.empty()) {
                  std::string msg = "SEMANTIC_ERROR:UNDECLARED:" + std::string($1) + ":" + std::to_string(currentUseLine);
                  Logger::log("Warning: Identifier '" + std::string($1) + "' not declared before use");
                  errorType = 3;
                  yyerror(msg.c_str());
        
                  $$ = new std::vector<std::string>();
            } else {
                  $$ = new std::vector<std::string>();
                  $$->push_back($1);
                  Logger::log("Reduced: relacao_classe_itens (single)");
            }    
      }
      | CONVENCAO_IDENTIFICADOR ',' relacao_classe_itens { 
            Symbol* symbol = symbolTable.lookup($1);

            int currentUseLine = symbol ? symbol->positions.back().first : 0;

            if (!symbol || symbol->construct.empty()) {
                  std::string msg = "SEMANTIC_ERROR:UNDECLARED:" + std::string($1) + ":" + std::to_string(currentUseLine);
                  Logger::log("Warning: Identifier '" + std::string($1) + "' not declared before use");
                  errorType = 3;
                  yyerror(msg.c_str());

                  $$ = $3;
            } else {
                  $$ = $3;
                  $$->insert($$->begin(), $1);
                  Logger::log("Reduced: relacao_classe_itens (multiple)");
            }
      }

data_types: 
      | NOVOS_TIPOS CONVENCAO_IDENTIFICADOR '{' atributos '}' { symbolTable.addConstruct($2, "DataType"); Logger::log("Reduced: data_types"); }


enumerations:
      | ENUM CONVENCAO_IDENTIFICADOR '{' enum_itens '}' { 
            symbolTable.addConstruct($2, "Enumeration"); 
            for (const auto& item : *$4) {
                symbolTable.addRelationship($2, (std::string("enum:") + item).c_str());
            }
            delete $4;
            Logger::log("Reduced: enumerations"); 
      }

enum_itens:
      | CONVENCAO_IDENTIFICADOR { 
            $$ = new std::vector<std::string>();
            $$->push_back($1);
            Logger::log("Reduced: enum_itens (single)"); 
      }
      | CONVENCAO_IDENTIFICADOR ',' enum_itens { 
            $$ = $3;
            $$->insert($$->begin(), $1);
            Logger::log("Reduced: enum_itens (multiple)"); 
      }


generalizacoes:
      | reservadas_genset GENSETS CONVENCAO_IDENTIFICADOR RESERVADAS generalizacao_itens ESTEREOTIPO_RELACOES CONVENCAO_IDENTIFICADOR { symbolTable.addConstruct($3, "Generalizacao"); Logger::log("Reduced: generalizacoes (with reservadas)"); }
      | reservadas_genset GENSETS CONVENCAO_IDENTIFICADOR '{' generalizacao_escopo '}' { symbolTable.addConstruct($3, "Generalizacao"); Logger::log("Reduced: generalizacoes (without reservadas)"); }
      | GENSETS CONVENCAO_IDENTIFICADOR RESERVADAS generalizacao_itens ESTEREOTIPO_RELACOES CONVENCAO_IDENTIFICADOR { symbolTable.addConstruct($2, "Generalizacao"); Logger::log("Reduced: generalizacoes (without reservadas)"); }
      | GENSETS CONVENCAO_IDENTIFICADOR RESERVADAS generalizacao_itens ESTEREOTIPO_RELACOES CONVENCAO_IDENTIFICADOR { symbolTable.addConstruct($2, "Generalizacao"); Logger::log("Reduced: generalizacoes"); }

reservadas_genset:
      | RESERVADAS { Logger::log("Reduced: reservadas_genset"); }
      | RESERVADAS reservadas_genset { Logger::log("Reduced: reservadas_genset (multiple)"); }

generalizacao_itens:
      | CONVENCAO_IDENTIFICADOR { 
            Symbol* symbol = symbolTable.lookup($1);
            
            int currentUseLine = symbol ? symbol->positions.back().first : 0;
            
            Logger::log("Symbol '" + std::string($1) + "' construct: " + (symbol ? symbol->construct : "(not found)"));
            
            if (!symbol || symbol->construct.empty()) {
                  std::string msg = "SEMANTIC_ERROR:UNDECLARED:" + std::string($1) + ":" + std::to_string(currentUseLine);
                  Logger::log("Warning: Identifier '" + std::string($1) + "' not declared before use");
                  errorType = 3;
                  yyerror(msg.c_str());
        
                  $$ = new std::vector<std::string>();
            } else {
                  $$ = new std::vector<std::string>();
                  $$->push_back($1);
            }
            Logger::log("Reduced: generalizacao_itens (single)"); 
      }
      | CONVENCAO_IDENTIFICADOR ',' generalizacao_itens { Logger::log("Reduced: generalizacao_itens (multiple)"); }

generalizacao_escopo:
      | RESERVADAS generalizacao_itens { Logger::log("Reduced: generalizacao_escopo (single)"); }
      | RESERVADAS generalizacao_itens generalizacao_escopo { Logger::log("Reduced: generalizacao_escopo (multiple)"); }


declaracao_relacoes:
      | ESTEREOTIPO_CLASSES CONVENCAO_IDENTIFICADOR '{' relacoes_escopo '}' { 
            symbolTable.addConstruct($2, $1);
            for (const auto& rel : *$4) {
                  symbolTable.addRelationship($2, rel.c_str());
            }
            Logger::log("Reduced: declaracao_relacoes"); 
      }
      | '@' ESTEREOTIPO_RELACOES RESERVADAS CONVENCAO_IDENTIFICADOR cardinalidade operador_relacao cardinalidade CONVENCAO_IDENTIFICADOR { 
            symbolTable.addConstruct($4, "Relacao"); 
            std::string rel = std::string($2) + ":" + std::string($8);
            symbolTable.addRelationship($4, rel.c_str());
            Logger::log("Reduced: declaracao_relacoes (with reservadas)"); 
      }
      | '@' ESTEREOTIPO_RELACOES RESERVADAS CONVENCAO_IDENTIFICADOR cardinalidade operador_relacao CONVENCAO_RELACOES operador_relacao cardinalidade CONVENCAO_IDENTIFICADOR { 
            symbolTable.addConstruct($4, "Relacao"); 
            std::string rel = std::string($2) + ":" + std::string($10);
            symbolTable.addRelationship($4, rel.c_str());
            Logger::log("Reduced: declaracao_relacoes (with reservadas)"); 
      }

relacoes_escopo:
      | '@' ESTEREOTIPO_RELACOES cardinalidade operador_relacao cardinalidade CONVENCAO_IDENTIFICADOR { 
            Symbol* symbol = symbolTable.lookup($6);
            int currentUseLine = symbol ? symbol->positions.back().first : getLineNo();
            
            if (!symbol || symbol->construct.empty()) {
                  std::string msg = "SEMANTIC_ERROR:UNDECLARED:" + std::string($6) + ":" + std::to_string(currentUseLine);
                  Logger::log("Warning: Identifier '" + std::string($6) + "' not declared before use");
                  errorType = 3;
                  yyerror(msg.c_str());
            }
            $$ = new std::vector<std::string>();
            $$->push_back(std::string($2) + ":" + $6);
            Logger::log("Reduced: relacao_item (stereotyped)"); 
      }
      | operador_relacao CONVENCAO_RELACOES operador_relacao cardinalidade CONVENCAO_IDENTIFICADOR { 
            Symbol* symbol = symbolTable.lookup($5);
            int currentUseLine = symbol ? symbol->positions.back().first : getLineNo();
            
            if (!symbol || symbol->construct.empty()) {
                  std::string msg = "SEMANTIC_ERROR:UNDECLARED:" + std::string($5) + ":" + std::to_string(currentUseLine);
                  Logger::log("Warning: Identifier '" + std::string($5) + "' not declared before use");
                  errorType = 3;
                  yyerror(msg.c_str());
            }
            $$ = new std::vector<std::string>();
            $$->push_back(std::string($2) + ":" + $5);
            Logger::log("Reduced: relacao_item (simple)"); 
      }
      | '@' ESTEREOTIPO_RELACOES operador_relacao CONVENCAO_RELACOES operador_relacao cardinalidade CONVENCAO_IDENTIFICADOR { 
            Symbol* symbol = symbolTable.lookup($7);
            int currentUseLine = symbol ? symbol->positions.back().first : getLineNo();
            
            if (!symbol || symbol->construct.empty()) {
                  std::string msg = "SEMANTIC_ERROR:UNDECLARED:" + std::string($7) + ":" + std::to_string(currentUseLine);
                  Logger::log("Warning: Identifier '" + std::string($7) + "' not declared before use");
                  errorType = 3;
                  yyerror(msg.c_str());
            }
            Logger::log("Reducao para criacao do vetor"); 
            $$ = new std::vector<std::string>();
            $$->push_back(std::string($2) + ":" + $7);
            Logger::log("Reduced: relacao_item (stereotyped simple)"); 
      }
      | '@' ESTEREOTIPO_RELACOES cardinalidade operador_relacao cardinalidade CONVENCAO_IDENTIFICADOR ',' relacoes_escopo { 
            Symbol* symbol = symbolTable.lookup($6);
            int currentUseLine = symbol ? symbol->positions.back().first : getLineNo();
            
            if (!symbol || symbol->construct.empty()) {
                  std::string msg = "SEMANTIC_ERROR:UNDECLARED:" + std::string($6) + ":" + std::to_string(currentUseLine);
                  Logger::log("Warning: Identifier '" + std::string($6) + "' not declared before use");
                  errorType = 3;
                  yyerror(msg.c_str());
            }
            $$ = $8;
            $$->insert($$->begin(), std::string($2) + ":" + $6);
            Logger::log("Reduced: relacao_item (stereotyped)"); 
      }
      | operador_relacao CONVENCAO_RELACOES operador_relacao cardinalidade CONVENCAO_IDENTIFICADOR ',' relacoes_escopo { 
            Symbol* symbol = symbolTable.lookup($5);
            int currentUseLine = symbol ? symbol->positions.back().first : getLineNo();
            
            if (!symbol || symbol->construct.empty()) {
                  std::string msg = "SEMANTIC_ERROR:UNDECLARED:" + std::string($5) + ":" + std::to_string(currentUseLine);
                  Logger::log("Warning: Identifier '" + std::string($5) + "' not declared before use");
                  errorType = 3;
                  yyerror(msg.c_str());
            }
            $$ = $7;
            $$->insert($$->begin(), std::string($2) + ":" + $5);
            Logger::log("Reduced: relacao_item (simple)"); 
      }
      | '@' ESTEREOTIPO_RELACOES operador_relacao CONVENCAO_RELACOES operador_relacao cardinalidade CONVENCAO_IDENTIFICADOR ',' relacoes_escopo { 
            Symbol* symbol = symbolTable.lookup($7);
            int currentUseLine = symbol ? symbol->positions.back().first : getLineNo();
            
            if (!symbol || symbol->construct.empty()) {
                  std::string msg = "SEMANTIC_ERROR:UNDECLARED:" + std::string($7) + ":" + std::to_string(currentUseLine);
                  Logger::log("Warning: Identifier '" + std::string($7) + "' not declared before use");
                  errorType = 3;
                  yyerror(msg.c_str());
            }
            Logger::log("Reducao pos criacao do vetor"); 
            $$ = $9;
            $$->insert($$->begin(), std::string($2) + ":" + $7);
            Logger::log("Reduced: relacao_item (stereotyped simple)"); 
      }


cardinalidade:
      | '[' NUM ']' { Logger::log("Reduced: cardinalidade (single)"); }
      | '[' NUM '.' '.' '*' ']' { Logger::log("Reduced: cardinalidade (unbounded)"); }
      | '[' NUM '.' '.' NUM ']' { Logger::log("Reduced: cardinalidade (range)"); }


operador_relacao:
      | '-''-' { Logger::log("Reduced: operador_relacao (undirected)"); }
      | '<''>''-''-' { Logger::log("Reduced: operador_relacao (stereotyped undirected)"); }

%%

void yyerror(const char *s) {
      Logger::log("Parse error: " + std::string(s));

      if (errorType == 0) {
            errorType = 2;
      }

      std::string errorMsg = s;
      std::string msg;

      if (errorMsg.find("SEMANTIC_ERROR:UNDECLARED:") == 0) {
            std::string remainder = errorMsg.substr(26); 
            size_t lastColon = remainder.rfind(':'); 
            
            std::string lexeme = remainder.substr(0, lastColon);
            std::string lineStr = remainder.substr(lastColon + 1);
            
            msg = "Semantic Error on line " + lineStr + ":\n";
            msg += "  The identifier '" + lexeme + "' was not declared before use.\n";
            msg += "  Hint: Declare '" + lexeme + "' with a class stereotype (e.g., 'kind " + lexeme + "') before using it.";
      } else {
            std::string expected = "";
            size_t expectingPos = errorMsg.find("expecting");
            if (expectingPos != std::string::npos) {
                expected = errorMsg.substr(expectingPos + 10);
            }

            msg = "Error on line " + std::to_string(getLineNo()) + ", lexeme '" + getCurrentLexeme() + "' (" + getCurrentTokenString() + ").";
            if (!expected.empty()) {
                msg += "\nExpecting a token " + expected + ".";
            }
      }

      std::string currentErrors = getSyntaxErrorMsg();
      if (!currentErrors.empty()) {
            setSyntaxErrorMsg(currentErrors + "\n\n" + msg);
      } else {
            setSyntaxErrorMsg(msg);
      }
}

int main() {
   startTUI();
   return 0;
}