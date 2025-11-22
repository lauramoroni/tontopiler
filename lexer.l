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
int yycolumn = 1;
%}

delim	                  [ \t\n]
brancos                   {delim}+
letra	                  [A-Za-z]
maiuscula                 [A-Z]
minuscula                 [a-z]
digito	                  [0-9]
num	                      {digito}+(\.{digito}+)?(E[+-]?{digito}+)?
estereotipoClasse	      event|situation|process|category|mixin|phaseMixin|roleMixin|historicalRoleMixin|kind|collective|quantity|quality|mode|intrisicMode|extrinsicMode|subkind|phase|role|historicalRole
estereotipoRelacao        material|derivation|comparative|mediation|characterization|externalDependence|componentOf|memberOf|subCollectionOf|subQualityOf|instantiation|termination|participational|participation|historicalDependence|creation|manifestation|bringsAbout|triggers|composition|aggregation|inherence|value|formal|constitution|specializes
reservadas                genset|disjoint|complete|general|specifics|where|relation
package                   package
tipoNativo                number|string|boolean|date|time|datetime
metaAtributos             ordered|const|derived|subsets|redefines
convencaoIdentificador    {maiuscula}{letra}*(_{letra}*)*
convencaoRelacoes         {minuscula}{letra}*(_{letra}+)*
convencaoInstancias       {letra}+_*{letra}*{digito}+
novosTipos                {letra}+DataType


%%
\n				          { 
                            yycolumn = 1; // reseta coluna no fim da linha
                          }
[ \t]+                    {
                            // espaços e tabs: atualiza coluna (tabs avançam para o próximo tab stop em 8)
                            for (int i = 0; i < yyleng; ++i) {
                                if (yytext[i] == '\t') {
                                    yycolumn = ((yycolumn - 1) / 8 + 1) * 8 + 1;
                                } else {
                                    yycolumn++;
                                }
                            }
                          }
{estereotipoClasse}       { symbolTable.insert(yytext, ESTEREOTIPO_CLASSES, yylineno, yycolumn); yycolumn += yyleng; }
{estereotipoRelacao}      { symbolTable.insert(yytext, ESTEREOTIPO_RELACOES, yylineno, yycolumn); yycolumn += yyleng; }
{reservadas}              { symbolTable.insert(yytext, RESERVADAS, yylineno, yycolumn); yycolumn += yyleng; }
{package}                 { symbolTable.insert(yytext, PACKAGE, yylineno, yycolumn); yycolumn += yyleng; }
{tipoNativo}              { symbolTable.insert(yytext, TIPOS_NATIVOS, yylineno, yycolumn); yycolumn += yyleng; }
{metaAtributos}           { symbolTable.insert(yytext, META_ATRIBUTOS, yylineno, yycolumn); yycolumn += yyleng; }
{novosTipos}              { symbolTable.insert(yytext, NOVOS_TIPOS, yylineno, yycolumn); yycolumn += yyleng; }
{convencaoIdentificador}  { symbolTable.insert(yytext, CONVENCAO_CLASSES, yylineno, yycolumn); yycolumn += yyleng; }
{convencaoRelacoes}       { symbolTable.insert(yytext, CONVENCAO_RELACOES, yylineno, yycolumn); yycolumn += yyleng; }
{convencaoInstancias}     { symbolTable.insert(yytext, CONVENCAO_INSTANCIAS, yylineno, yycolumn); yycolumn += yyleng; }
{num}                     { symbolTable.insert(yytext, NUM, yylineno, yycolumn); yycolumn += yyleng; }
"<"                       { symbolTable.insert(yytext, SIMBOLOS, yylineno, yycolumn); yycolumn += yyleng; }
">"                       { symbolTable.insert(yytext, SIMBOLOS, yylineno, yycolumn); yycolumn += yyleng; }
"{"                       { symbolTable.insert(yytext, SIMBOLOS, yylineno, yycolumn); yycolumn += yyleng; }
"}"                       { symbolTable.insert(yytext, SIMBOLOS, yylineno, yycolumn); yycolumn += yyleng; }
"("                       { symbolTable.insert(yytext, SIMBOLOS, yylineno, yycolumn); yycolumn += yyleng; }
")"                       { symbolTable.insert(yytext, SIMBOLOS, yylineno, yycolumn); yycolumn += yyleng; }
"["                       { symbolTable.insert(yytext, SIMBOLOS, yylineno, yycolumn); yycolumn += yyleng; }
"]"                       { symbolTable.insert(yytext, SIMBOLOS, yylineno, yycolumn); yycolumn += yyleng; }
"-"                       { symbolTable.insert(yytext, SIMBOLOS, yylineno, yycolumn); yycolumn += yyleng; }
"--"                      { symbolTable.insert(yytext, SIMBOLOS, yylineno, yycolumn); yycolumn += yyleng; }
"..."                     { symbolTable.insert(yytext, SIMBOLOS, yylineno, yycolumn); yycolumn += yyleng; }
"<>--"                    { symbolTable.insert(yytext, SIMBOLOS, yylineno, yycolumn); yycolumn += yyleng; }
"--<>"                    { symbolTable.insert(yytext, SIMBOLOS, yylineno, yycolumn); yycolumn += yyleng; }
"*"                       { symbolTable.insert(yytext, SIMBOLOS, yylineno, yycolumn); yycolumn += yyleng; }
"@"                       { symbolTable.insert(yytext, SIMBOLOS, yylineno, yycolumn); yycolumn += yyleng; }
":"                       { symbolTable.insert(yytext, SIMBOLOS, yylineno, yycolumn); yycolumn += yyleng; }
";"                       { symbolTable.insert(yytext, SIMBOLOS, yylineno, yycolumn); yycolumn += yyleng; }
","{brancos}              { symbolTable.insert(yytext, SIMBOLOS, yylineno, yycolumn); yycolumn += yyleng; }
"<o>--"                   { symbolTable.insert(yytext, SIMBOLOS, yylineno, yycolumn); yycolumn += yyleng; }
"--<o>"                   { symbolTable.insert(yytext, SIMBOLOS, yylineno, yycolumn); yycolumn += yyleng; }
.                         {
                           symbolTable.insert(yytext, TOKEN_DESCONHECIDO, yylineno, yycolumn);
                           // Imprime o erro no cerr, que não será capturado pelo ncurses
                           fprintf(stderr, "Erro Léxico: Caractere inesperado '%s' na linha %d, coluna %d\n", yytext, yylineno, yycolumn);
                           hasError = true;
                           yycolumn += yyleng;
                          }
%%


int main(int argc, char **argv) {
    startTUI();
    return 0;
}

int yyFlexLexer::yywrap() {
    return 1;
}