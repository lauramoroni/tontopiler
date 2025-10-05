// declarações
%{
#include <iostream>
#include "token.h"
using namespace std;
%}

%option noyywrap


// definições de padrões léxicos
delim	                [ \t\n]
brancos               {delim}+
letra	                [A-Za-z]
maiuscula             [A-Z]
minuscula             [a-z]
digito	             [0-9]
id	                   {letra}({letra}|{digito})*
num	                {digito}+(\.{digito}+)?(E[+-]?{digito}+)?

estereotipoClasse	    event|situation|process|category|mixin|phaseMixin|roleMixin|historicalRoleMixin|kind|collective|quantity|quality|mode|intrisicMode|extrinsicMode|subkind|phase|role|historicalRole
estereotipoRelacao    material|derivation|comparative|mediation|characterization|externalDependence|componentOf|memberOf|subCollectionOf|subQualityOf|instantiation|termination|participational|participation|historicalDependence|creation|manifestation|bringsAbout|triggers|composition|aggregation|inherence|value|formal|constitution
reservadas            genset|disjoint|complete|general|specifics|where|package
tipoNativo            number|string|boolean|date|time|datetime
metaAtributos         ordered|const|derived|subsets|redefines

convencaoClasses      {maiuscula}{letra}*(_{letra}+)*
convencaoRelacoes     {minuscula}{letra}*(_{letra}+)*
convencaoInstancias   {letra}+_*{letra}*{digito}+
novosTipos            {letra}+DataType


%% 
// regras de tradução
{brancos}	;
{reservadas} return RESERVADAS;
{estereotipoClasse} return ESTEREOTIPO_CLASSES;
{estereotipoRelacao} return ESTEREOTIPO_RELACOES;
{id}         return ID;
{num}        return NUM;
"<"          return SIMBOLOS;
">"          return SIMBOLOS;
"{"          return SIMBOLOS;
"}"          return SIMBOLOS;
"("          return SIMBOLOS;
")"          return SIMBOLOS;
"["          return SIMBOLOS;
"]"          return SIMBOLOS;
"..."        return SIMBOLOS;
"<>--"       return SIMBOLOS;
"--<>"       return SIMBOLOS;
"*"          return SIMBOLOS;
"@"          return SIMBOLOS;
":"          return SIMBOLOS;

%%