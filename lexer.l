%{
#include <iostream>
using namespace std;

enum {
    ID,
    NUM,
    ESTEREOTIPO_CLASSES,
    ESTEREOTIPO_RELACOES,
    RESERVADAS,
    SIMBOLOS,
    CONVENCAO_CLASSES,
    CONVENCAO_RELACOES,
    CONVENCAO_INSTANCIAS,
    TIPOS_NATIVOS,
    NOVOS_TIPOS,
    META_ATRIBUTOS
};
%}

%option noyywrap


delim	              [ \t\n]
brancos               {delim}+
letra	              [A-Za-z]
maiuscula             [A-Z]
minuscula             [a-z]
digito	              [0-9]
id	                  {letra}({letra}|{digito})*
num	                  {digito}+(\.{digito}+)?(E[+-]?{digito}+)?

estereotipoClasse	  event|situation|process|category|mixin|phaseMixin|roleMixin|historicalRoleMixin|kind|collective|quantity|quality|mode|intrisicMode|extrinsicMode|subkind|phase|role|historicalRole
estereotipoRelacao    material|derivation|comparative|mediation|characterization|externalDependence|componentOf|memberOf|subCollectionOf|subQualityOf|instantiation|termination|participational|participation|historicalDependence|creation|manifestation|bringsAbout|triggers|composition|aggregation|inherence|value|formal|constitution
reservadas            genset|disjoint|complete|general|specifics|where|package
tipoNativo            number|string|boolean|date|time|datetime
metaAtributos         ordered|const|derived|subsets|redefines

convencaoClasses      {maiuscula}{letra}*(_{letra}+)*
convencaoRelacoes     {minuscula}{letra}*(_{letra}+)*
convencaoInstancias   {letra}+_*{letra}*{digito}+
novosTipos            {letra}+DataType


%% 
\n                    ;
{brancos}	          ;
{estereotipoClasse}   cout << "ESTEREOTIPO_CLASSE: " << yytext << endl;
{estereotipoRelacao}  cout << "ESTEREOTIPO_RELACAO: " << yytext << endl;
{reservadas}          cout << "RESERVADA: " << yytext << endl;
{tipoNativo}          cout << "TIPO_NATIVO: " << yytext << endl;
{metaAtributos}       cout << "META_ATRIBUTO: " << yytext << endl;

{novosTipos}          cout << "NOVO_TIPO: " << yytext << endl;
{convencaoClasses}    cout << "CONVENCAO_CLASSE: " << yytext << endl;
{convencaoRelacoes}   cout << "CONVENCAO_RELACAO: " << yytext << endl;
{convencaoInstancias} cout << "CONVENCAO_INSTANCIA: " << yytext << endl;

{id}                  cout << "ID: " << yytext << endl;
{num}                 cout << "NUM: " << yytext << endl;

"<"                   cout << "SIMBOLO: " << yytext << endl;
">"                   cout << "SIMBOLO: " << yytext << endl;
"{"                   cout << "SIMBOLO: " << yytext << endl;
"}"                   cout << "SIMBOLO: " << yytext << endl;
"("                   cout << "SIMBOLO: " << yytext << endl;
")"                   cout << "SIMBOLO: " << yytext << endl;
"["                   cout << "SIMBOLO: " << yytext << endl;
"]"                   cout << "SIMBOLO: " << yytext << endl;
"..."                 cout << "SIMBOLO: " << yytext << endl;
"<>--"                cout << "SIMBOLO: " << yytext << endl;
"--<>"                cout << "SIMBOLO: " << yytext << endl;
"*"                   cout << "SIMBOLO: " << yytext << endl;
"@"                   cout << "SIMBOLO: " << yytext << endl;
":"                   cout << "SIMBOLO: " << yytext << endl;
";"                   cout << "SIMBOLO: " << yytext << endl;
"<o>--"                cout << "SIMBOLO: " << yytext << endl;
"--<o>"                cout << "SIMBOLO: " << yytext << endl;

%%

int main()
{
	yyFlexLexer lexer;
	lexer.yylex();
}