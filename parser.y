%{
#include "TUI.h"
#include "Logger.h"

int yylex(void);
int yyparse(void);
void yyerror(const char *s);
extern bool hasError;
%}

%union {
    char* str;
}

%token <str> NUM
%token <str> ESTEREOTIPO_CLASSES
%token <str> ESTEREOTIPO_RELACOES
%token <str> RESERVADAS
%token <str> PACKAGE
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

%%
ontology: 
      | package_declaration ontology_body { Logger::log("Reduced: ontology"); }

ontology_body:
      | classes { Logger::log("Reduced: ontology_body -> classes"); }
      | classes ontology_body { Logger::log("Reduced: ontology_body -> classes ontology_body"); }
      | data_types { Logger::log("Reduced: ontology_body -> data_types"); }
      | data_types ontology_body { Logger::log("Reduced: ontology_body -> data_types ontology_body"); }
      | enumerations { Logger::log("Reduced: ontology_body -> enumerations"); }
      | enumerations ontology_body { Logger::log("Reduced: ontology_body -> enumerations ontology_body"); }

package_declaration: 
      | PACKAGE CONVENCAO_IDENTIFICADOR { Logger::log("Reduced: package_declaration"); }

classes:
      | classe { Logger::log("Reduced: classes -> classe"); }
      | classe classes { Logger::log("Reduced: classes -> classe classes"); }

classe:
      | ESTEREOTIPO_CLASSES CONVENCAO_IDENTIFICADOR { Logger::log("Reduced: classe (simple)"); }
      | ESTEREOTIPO_CLASSES CONVENCAO_IDENTIFICADOR '{' atributos '}' { Logger::log("Reduced: classe (with attributes)"); }

atributos:
      | atributo
      | atributo atributos

atributo:
      | CONVENCAO_RELACOES ':' TIPOS_NATIVOS { Logger::log("Reduced: atributo (native)"); }
      | CONVENCAO_RELACOES ':' NOVOS_TIPOS { Logger::log("Reduced: atributo (custom)"); }
      | CONVENCAO_RELACOES ':' TIPOS_NATIVOS '{' META_ATRIBUTOS '}' { Logger::log("Reduced: atributo (native with meta)"); }
      | CONVENCAO_RELACOES ':' NOVOS_TIPOS '{' META_ATRIBUTOS '}' { Logger::log("Reduced: atributo (custom with meta)"); }

relacao_classe:
      | ESTEREOTIPO_CLASSES CONVENCAO_IDENTIFICADOR ESTEREOTIPO_RELACOES CONVENCAO_IDENTIFICADOR { Logger::log("Reduced: relacao_classe"); }

data_types: 
      | NOVOS_TIPOS CONVENCAO_IDENTIFICADOR '{' atributos '}' { Logger::log("Reduced: data_types"); }

enumerations:
      | ENUM CONVENCAO_IDENTIFICADOR '{' enum_itens '}' { Logger::log("Reduced: enumerations"); }

enum_itens:
      | CONVENCAO_INSTANCIAS { Logger::log("Reduced: enum_itens (single)"); }
      | CONVENCAO_INSTANCIAS ',' enum_itens { Logger::log("Reduced: enum_itens (multiple)"); }

generalizacoes:
        | reservadas_genset GENSETS CONVENCAO_IDENTIFICADOR RESERVADAS generalizacao_itens ESTEREOTIPO_RELACOES CONVENCAO_IDENTIFICADOR { Logger::log("Reduced: generalizacoes (with reservadas)"); }
        | GENSETS CONVENCAO_IDENTIFICADOR RESERVADAS generalizacao_itens ESTEREOTIPO_RELACOES CONVENCAO_IDENTIFICADOR { Logger::log("Reduced: generalizacoes (without reservadas)"); }
        | GENSETS CONVENCAO_IDENTIFICADOR RESERVADAS generalizacao_itens ESTEREOTIPO_RELACOES CONVENCAO_IDENTIFICADOR { Logger::log("Reduced: generalizacoes"); }

reservadas_genset:
        | RESERVADAS { Logger::log("Reduced: reservadas_genset"); }
        | RESERVADAS reservadas_genset { Logger::log("Reduced: reservadas_genset (multiple)"); }

generalizacao_itens:
        | CONVENCAO_IDENTIFICADOR { Logger::log("Reduced: generalizacao_itens (single)"); }
        | CONVENCAO_IDENTIFICADOR ',' generalizacao_itens { Logger::log("Reduced: generalizacao_itens (multiple)"); }


declaracao_relacoes:
        | ESTEREOTIPO_CLASSES CONVENCAO_IDENTIFICADOR '{' relacoes_escopo '}' { Logger::log("Reduced: declaracao_relacoes"); }
        | '@' ESTEREOTIPO_RELACOES RESERVADAS CONVENCAO_IDENTIFICADOR cardinalidade '-''-' cardinalidade CONVENCAO_IDENTIFICADOR { Logger::log("Reduced: declaracao_relacoes (with reservadas)"); }

relacoes_escopo:
        | '@' ESTEREOTIPO_RELACOES cardinalidade '<''>''-''-' cardinalidade CONVENCAO_IDENTIFICADOR { Logger::log("Reduced: relacoes_escopo"); }

cardinalidade:
        | '[' NUM ']' { Logger::log("Reduced: cardinalidade (single)"); }
        | '[' NUM '.' '.' '*' ']' { Logger::log("Reduced: cardinalidade (unbounded)"); }
        | '[' NUM '.' '.' NUM ']' { Logger::log("Reduced: cardinalidade (range)"); }

%%

void yyerror(const char *s) {
    Logger::log("Parse error: " + std::string(s));
    fprintf(stderr, "Parse error: %s\n", s);
    hasError = true;
}

int main() {
   startTUI();

   return 0;
}