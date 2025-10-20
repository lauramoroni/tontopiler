%option yylineno

%{
#include <iostream>
#include <fstream>
#include <vector>
#include <string>

#include "SymbolTable.h"
#include "token.h"
#include "TUI.h"

using namespace std;


SymbolTable symbolTable;
bool hasError = false;
%}

delim	                  [ \t\n]
brancos                   {delim}+
letra	                  [A-Za-z]
maiuscula                 [A-Z]
minuscula                 [a-z]
digito	                  [0-9]
num	                      {digito}+(\.{digito}+)?(E[+-]?{digito}+)?
estereotipoClasse	      event|situation|process|category|mixin|phaseMixin|roleMixin|historicalRoleMixin|kind|collective|quantity|quality|mode|intrisicMode|extrinsicMode|subkind|phase|role|historicalRole
estereotipoRelacao        material|derivation|comparative|mediation|characterization|externalDependence|componentOf|memberOf|subCollectionOf|subQualityOf|instantiation|termination|participational|participation|historicalDependence|creation|manifestation|bringsAbout|triggers|composition|aggregation|inherence|value|formal|constitution
reservadas                genset|disjoint|complete|general|specifics|where|package
tipoNativo                number|string|boolean|date|time|datetime
metaAtributos             ordered|const|derived|subsets|redefines
convencaoIdentificador    {maiuscula}{letra}*(_{letra}*)*
convencaoRelacoes         {minuscula}{letra}*(_{letra}+)*
convencaoInstancias       {letra}+_*{letra}*{digito}+
novosTipos                {letra}+DataType


%%
{brancos}	              ;
{estereotipoClasse}       symbolTable.insert(yytext, ESTEREOTIPO_CLASSES, yylineno);
{estereotipoRelacao}      symbolTable.insert(yytext, ESTEREOTIPO_RELACOES, yylineno);
{reservadas}              symbolTable.insert(yytext, RESERVADAS, yylineno);
{tipoNativo}              symbolTable.insert(yytext, TIPOS_NATIVOS, yylineno);
{metaAtributos}           symbolTable.insert(yytext, META_ATRIBUTOS, yylineno);
{novosTipos}              symbolTable.insert(yytext, NOVOS_TIPOS, yylineno);
{convencaoIdentificador}  symbolTable.insert(yytext, CONVENCAO_CLASSES, yylineno);
{convencaoRelacoes}       symbolTable.insert(yytext, CONVENCAO_RELACOES, yylineno);
{convencaoInstancias}     symbolTable.insert(yytext, CONVENCAO_INSTANCIAS, yylineno);
{num}                     symbolTable.insert(yytext, NUM, yylineno);
"<"                       symbolTable.insert(yytext, SIMBOLOS, yylineno);
">"                       symbolTable.insert(yytext, SIMBOLOS, yylineno);
"{"                       symbolTable.insert(yytext, SIMBOLOS, yylineno);
"}"                       symbolTable.insert(yytext, SIMBOLOS, yylineno);
"("                       symbolTable.insert(yytext, SIMBOLOS, yylineno);
")"                       symbolTable.insert(yytext, SIMBOLOS, yylineno);
"["                       symbolTable.insert(yytext, SIMBOLOS, yylineno);
"]"                       symbolTable.insert(yytext, SIMBOLOS, yylineno);
"-"                       symbolTable.insert(yytext, SIMBOLOS, yylineno);
"--"                      symbolTable.insert(yytext, SIMBOLOS, yylineno);
"..."                     symbolTable.insert(yytext, SIMBOLOS, yylineno);
"<>--"                    symbolTable.insert(yytext, SIMBOLOS, yylineno);
"--<>"                    symbolTable.insert(yytext, SIMBOLOS, yylineno);
"*"                       symbolTable.insert(yytext, SIMBOLOS, yylineno);
"@"                       symbolTable.insert(yytext, SIMBOLOS, yylineno);
":"                       symbolTable.insert(yytext, SIMBOLOS, yylineno);
";"                       symbolTable.insert(yytext, SIMBOLOS, yylineno);
","{brancos}              symbolTable.insert(yytext, SIMBOLOS, yylineno);
"<o>--"                   symbolTable.insert(yytext, SIMBOLOS, yylineno);
"--<o>"                   symbolTable.insert(yytext, SIMBOLOS, yylineno);
.                         {
                           symbolTable.insert(yytext, TOKEN_DESCONHECIDO, yylineno);
                           // Imprime o erro no cerr, que não será capturado pelo ncurses
                           fprintf(stderr, "Erro Léxico: Caractere inesperado '%s' na linha %d\n", yytext, yylineno);
                           hasError = true;
                          }
%%


int main(int argc, char **argv) {
    startTUI();
    return 0;
}

int yyFlexLexer::yywrap() {
    return 1;
}