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
      | package_declaration ontology_body

ontology_body:
      | classes
      | classes ontology_body
      | data_types
      | data_types ontology_body
      | enumerations
      | enumerations ontology_body

package_declaration: 
      | PACKAGE CONVENCAO_IDENTIFICADOR

classes:
      | classe
      | classe classes

classe:
      | ESTEREOTIPO_CLASSES CONVENCAO_IDENTIFICADOR
      | ESTEREOTIPO_CLASSES CONVENCAO_IDENTIFICADOR '{' atributos '}'

atributos:
      | CONVENCAO_RELACOES ':' TIPOS_NATIVOS
      | CONVENCAO_RELACOES ':' NOVOS_TIPOS
      | CONVENCAO_RELACOES ':' TIPOS_NATIVOS '{' META_ATRIBUTOS '}'
      | CONVENCAO_RELACOES ':' NOVOS_TIPOS '{' META_ATRIBUTOS '}'

relacao_classe:
      | ESTEREOTIPO_CLASSES CONVENCAO_IDENTIFICADOR ESTEREOTIPO_RELACOES CONVENCAO_IDENTIFICADOR

data_types: 
      | NOVOS_TIPOS CONVENCAO_IDENTIFICADOR '{' atributos '}'

enumerations:
      | ENUM CONVENCAO_IDENTIFICADOR '{' enum_itens '}'

enum_itens:
      | CONVENCAO_INSTANCIAS
      | CONVENCAO_INSTANCIAS ',' enum_itens


generalizacoes:
        | reservadas_genset GENSETS CONVENCAO_IDENTIFICADOR RESERVADAS generalizacao_itens ESTEREOTIPO_RELACOES CONVENCAO_IDENTIFICADOR
        | GENSETS CONVENCAO_IDENTIFICADOR RESERVADAS generalizacao_itens ESTEREOTIPO_RELACOES CONVENCAO_IDENTIFICADOR
        | GENSETS CONVENCAO_IDENTIFICADOR RESERVADAS generalizacao_itens ESTEREOTIPO_RELACOES CONVENCAO_IDENTIFICADOR

reservadas_genset:
        | RESERVADAS
        | RESERVADAS reservadas_genset

generalizacao_itens:
        | CONVENCAO_IDENTIFICADOR
        | CONVENCAO_IDENTIFICADOR ',' generalizacao_itens


declaracao_relacoes:
        | ESTEREOTIPO_CLASSES CONVENCAO_IDENTIFICADOR '{' relacoes_escopo '}'
        | '@' ESTEREOTIPO_RELACOES RESERVADAS CONVENCAO_IDENTIFICADOR cardinalidade '-''-' cardinalidade CONVENCAO_IDENTIFICADOR

relacoes_escopo:
        | '@' ESTEREOTIPO_RELACOES cardinalidade '<''>''-''-' cardinalidade CONVENCAO_IDENTIFICADOR

cardinalidade:
        | '[' NUM ']'
        | '[' NUM '.' '.' '*' ']'
        | '[' NUM '.' '.' NUM ']'

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