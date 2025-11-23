%option yylineno

%{
#include <iostream>
#include <fstream>
#include <vector>
#include <string>

#include "SymbolTable.h"
#include "token.h"

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
reservadas                disjoint|complete|general|specifics|where|relation
package                   package
genset                    genset
tipoNativo                number|string|boolean|date|time|datetime
metaAtributos             ordered|const|derived|subsets|redefines
enum                      enum
convencaoIdentificador    {maiuscula}{letra}*(_{letra}*)*
convencaoRelacoes         {minuscula}{letra}*(_{letra}+)*
convencaoInstancias       {letra}+_*{letra}*{digito}+
novosTipos                {letra}+Type


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
{estereotipoClasse}       { symbolTable.insert(yytext, ESTEREOTIPO_CLASSES, yylineno, yycolumn); yycolumn += yyleng; return ESTEREOTIPO_CLASSES; }
{estereotipoRelacao}      { symbolTable.insert(yytext, ESTEREOTIPO_RELACOES, yylineno, yycolumn); yycolumn += yyleng; return ESTEREOTIPO_RELACOES; }
{reservadas}              { symbolTable.insert(yytext, RESERVADAS, yylineno, yycolumn); yycolumn += yyleng; return RESERVADAS; }
{package}                 { symbolTable.insert(yytext, PACKAGE, yylineno, yycolumn); yycolumn += yyleng; return PACKAGE; }
{genset}                  { symbolTable.insert(yytext, GENSETS, yylineno, yycolumn); yycolumn += yyleng; return GENSETS; }
{tipoNativo}              { symbolTable.insert(yytext, TIPOS_NATIVOS, yylineno, yycolumn); yycolumn += yyleng; return TIPOS_NATIVOS; }
{metaAtributos}           { symbolTable.insert(yytext, META_ATRIBUTOS, yylineno, yycolumn); yycolumn += yyleng; return META_ATRIBUTOS; }
{enum}                    { symbolTable.insert(yytext, ENUM, yylineno, yycolumn); yycolumn += yyleng; return ENUM; }
{novosTipos}              { symbolTable.insert(yytext, NOVOS_TIPOS, yylineno, yycolumn); yycolumn += yyleng; return NOVOS_TIPOS; }
{convencaoIdentificador}  { symbolTable.insert(yytext, CONVENCAO_IDENTIFICADOR, yylineno, yycolumn); yycolumn += yyleng; return CONVENCAO_IDENTIFICADOR; }
{convencaoRelacoes}       { symbolTable.insert(yytext, CONVENCAO_RELACOES, yylineno, yycolumn); yycolumn += yyleng; return CONVENCAO_RELACOES; }
{convencaoInstancias}     { symbolTable.insert(yytext, CONVENCAO_INSTANCIAS, yylineno, yycolumn); yycolumn += yyleng; return CONVENCAO_INSTANCIAS; }
{num}                     { symbolTable.insert(yytext, NUM, yylineno, yycolumn); yycolumn += yyleng; return NUM; }
"<"                       { symbolTable.insert(yytext, SIMBOLOS, yylineno, yycolumn); yycolumn += yyleng; return '<'; }
">"                       { symbolTable.insert(yytext, SIMBOLOS, yylineno, yycolumn); yycolumn += yyleng; return '>'; }
"{"                       { symbolTable.insert(yytext, SIMBOLOS, yylineno, yycolumn); yycolumn += yyleng; return '{'; }
"}"                       { symbolTable.insert(yytext, SIMBOLOS, yylineno, yycolumn); yycolumn += yyleng; return '}'; }
"("                       { symbolTable.insert(yytext, SIMBOLOS, yylineno, yycolumn); yycolumn += yyleng; return '('; }
")"                       { symbolTable.insert(yytext, SIMBOLOS, yylineno, yycolumn); yycolumn += yyleng; return ')'; }
"["                       { symbolTable.insert(yytext, SIMBOLOS, yylineno, yycolumn); yycolumn += yyleng; return '['; }
"]"                       { symbolTable.insert(yytext, SIMBOLOS, yylineno, yycolumn); yycolumn += yyleng; return ']'; }
"-"                       { symbolTable.insert(yytext, SIMBOLOS, yylineno, yycolumn); yycolumn += yyleng; return '-'; }
"*"                       { symbolTable.insert(yytext, SIMBOLOS, yylineno, yycolumn); yycolumn += yyleng; return '*'; }
"@"                       { symbolTable.insert(yytext, SIMBOLOS, yylineno, yycolumn); yycolumn += yyleng; return '@'; }
":"                       { symbolTable.insert(yytext, SIMBOLOS, yylineno, yycolumn); yycolumn += yyleng; return ':'; }
";"                       { symbolTable.insert(yytext, SIMBOLOS, yylineno, yycolumn); yycolumn += yyleng; return ';'; }
"."                       { symbolTable.insert(yytext, SIMBOLOS, yylineno, yycolumn); yycolumn += yyleng; return '.'; }
","{brancos}              { symbolTable.insert(yytext, SIMBOLOS, yylineno, yycolumn); yycolumn += yyleng; return ','; }
.                         {
                           symbolTable.insert(yytext, TOKEN_DESCONHECIDO, yylineno, yycolumn);
                           hasError = true;
                           yycolumn += yyleng;
                          }
%%

int yyFlexLexer::yywrap() {
    return 1;
}

