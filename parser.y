%{
#include "token.h"

int yylex(void);
int yyparse(void);
void yyerror(const char *s);
%}

%union {
    char* str;
}

%token <str> NUM
%token <str> ESTEREOTIPO_CLASSES
%token <str> ESTEREOTIPO_RELACOES
%token <str> RESERVADAS
%token <str> PACKAGE
%token <str> CONVENCAO_CLASSES
%token <str> CONVENCAO_RELACOES
%token <str> CONVENCAO_INSTANCIAS
%token <str> TIPOS_NATIVOS
%token <str> NOVOS_TIPOS
%token <str> META_ATRIBUTOS
%token <str> ENUM

%%

// gramáticas
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
      | PACKAGE CONVENCAO_CLASSES

classes:
      | classe
      | classe classes

classe:
      | ESTEREOTIPO_CLASSES CONVENCAO_CLASSES
      | ESTEREOTIPO_CLASSES CONVENCAO_CLASSES '{' atributos '}'

atributos:
      | CONVENCAO_RELACOES ':' TIPOS_NATIVOS
      | CONVENCAO_RELACOES ':' NOVOS_TIPOS
      | CONVENCAO_RELACOES ':' TIPOS_NATIVOS '{' META_ATRIBUTOS '}'
      | CONVENCAO_RELACOES ':' NOVOS_TIPOS '{' META_ATRIBUTOS '}'

relacao_classe:
      | ESTEREOTIPO_CLASSES CONVENCAO_CLASSES ESTEREOTIPO_RELACOES CONVENCAO_CLASSES

data_types: 
      | NOVOS_TIPOS CONVENCAO_CLASSES '{' atributos '}'

enumerations:
      | ENUM CONVENCAO_CLASSES '{' enum_itens '}'

enum_itens:
      | CONVENCAO_INSTANCIAS
      | CONVENCAO_INSTANCIAS ',' enum_itens

%%