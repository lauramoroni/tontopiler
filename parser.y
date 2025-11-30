%{
#include "TUI.h"
#include "Logger.h"
#include "SymbolTable.h"
#include <cstring>

extern SymbolTable symbolTable;
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

%type <str> relacao_item

%%
ontology: 
      | package_declaration ontology_body { Logger::log("Reduced: ontology with package"); }

ontology_body:
      | element { Logger::log("Reduced: ontology_body -> element"); }
      | element ontology_body { Logger::log("Reduced: ontology_body -> element ontology_body"); }

package_declaration: 
      | PACKAGE CONVENCAO_IDENTIFICADOR { symbolTable.addConstruct($2, "Package"); Logger::log("Reduced: package_declaration"); }
      | IMPORT CONVENCAO_IDENTIFICADOR { symbolTable.addConstruct($2, "Import"); Logger::log("Reduced: package_declaration (import)"); }

element:
      | package_declaration { Logger::log("Reduced: element -> package_declaration"); }
      | classe { Logger::log("Reduced: element -> classe"); }
      | relacao_classe { Logger::log("Reduced: element -> relacao_classe"); }
      | data_types { Logger::log("Reduced: element -> data_types"); }
      | enumerations { Logger::log("Reduced: element -> enumerations"); }
      | generalizacoes { Logger::log("Reduced: element -> generalizacoes"); }
      | declaracao_relacoes { Logger::log("Reduced: element -> declaracao_relacoes"); }

classe:
      | ESTEREOTIPO_CLASSES CONVENCAO_IDENTIFICADOR { symbolTable.addConstruct($2, "Classe"); Logger::log("Reduced: classe (simple)"); }
      | ESTEREOTIPO_CLASSES CONVENCAO_IDENTIFICADOR '{' atributos '}' { symbolTable.addConstruct($2, "Classe"); Logger::log("Reduced: classe (with attributes)"); }

atributos:
      | atributo
      | atributo atributos

atributo:
      | CONVENCAO_RELACOES ':' TIPOS_NATIVOS { Logger::log("Reduced: atributo (native)"); }
      | CONVENCAO_RELACOES ':' NOVOS_TIPOS { Logger::log("Reduced: atributo (custom)"); }
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
          $$ = new std::vector<std::string>();
          $$->push_back($1);
          Logger::log("Reduced: relacao_classe_itens (single)"); 
      }
      | CONVENCAO_IDENTIFICADOR ',' relacao_classe_itens { 
          $$ = $3;
          $$->insert($$->begin(), $1);
          Logger::log("Reduced: relacao_classe_itens (multiple)"); 
      }

data_types: 
      | NOVOS_TIPOS CONVENCAO_IDENTIFICADOR '{' atributos '}' { symbolTable.addConstruct($2, "DataType"); Logger::log("Reduced: data_types"); }


enumerations:
      | ENUM CONVENCAO_IDENTIFICADOR '{' enum_itens '}' { 
            symbolTable.addConstruct($2, "Enumeration"); 
            for (const auto& item : *$4) {
                symbolTable.addRelationship($2, (string("enum:") + item).c_str());
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
      | CONVENCAO_IDENTIFICADOR { Logger::log("Reduced: generalizacao_itens (single)"); }
      | CONVENCAO_IDENTIFICADOR ',' generalizacao_itens { Logger::log("Reduced: generalizacao_itens (multiple)"); }

generalizacao_escopo:
      | RESERVADAS generalizacao_itens { Logger::log("Reduced: generalizacao_escopo (single)"); }
      | RESERVADAS generalizacao_itens generalizacao_escopo { Logger::log("Reduced: generalizacao_escopo (multiple)"); }

declaracao_relacoes:
      | ESTEREOTIPO_CLASSES CONVENCAO_IDENTIFICADOR '{' relacoes_escopo '}' { 
            symbolTable.addConstruct($2, "Classe");
            Logger::log("Reduced: declaracao_relacoes"); 
      }
      | '@' ESTEREOTIPO_RELACOES RESERVADAS CONVENCAO_IDENTIFICADOR cardinalidade '-''-' cardinalidade CONVENCAO_IDENTIFICADOR { 
            symbolTable.addConstruct($4, "Relacao"); 
            std::string rel = string($2) + ":" + string($9);
            symbolTable.addRelationship($4, rel.c_str());
            Logger::log("Reduced: declaracao_relacoes (with reservadas)"); 
      }

relacoes_escopo:
      | relacao_item { Logger::log("Reduced: relacoes_escopo (single)"); }
      | relacao_item relacoes_escopo { Logger::log("Reduced: relacoes_escopo (recursive)"); }

relacao_item:
      | '@' ESTEREOTIPO_RELACOES cardinalidade '<''>''-''-' cardinalidade CONVENCAO_IDENTIFICADOR { Logger::log("Reduced: relacao_item (stereotyped)"); }
      | '-''-' CONVENCAO_RELACOES '-''-' cardinalidade CONVENCAO_IDENTIFICADOR { Logger::log("Reduced: relacao_item (simple)"); }
      | '@' ESTEREOTIPO_RELACOES '-''-' CONVENCAO_RELACOES '-''-' cardinalidade CONVENCAO_IDENTIFICADOR { Logger::log("Reduced: relacao_item (stereotyped simple)"); }


cardinalidade:
      | '[' NUM ']' { Logger::log("Reduced: cardinalidade (single)"); }
      | '[' NUM '.' '.' '*' ']' { Logger::log("Reduced: cardinalidade (unbounded)"); }
      | '[' NUM '.' '.' NUM ']' { Logger::log("Reduced: cardinalidade (range)"); }

%%

void yyerror(const char *s) {
    Logger::log("Parse error: " + std::string(s));
    fprintf(stderr, "Parse error: %s\n", s);
    if (errorType == 0) {
        errorType = 2;
    }
}

int main() {
   startTUI();

   return 0;
}