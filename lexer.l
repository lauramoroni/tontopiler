   // declarações
%{
#include <iostream>
#include "token.h"
using namespace std;
%}

%option noyywrap

delim	              [ \t\n]
brancos             {delim}+
letra	              [A-Za-z]
digito	           [0-9]
id	                 {letra}({letra}|{digito})*
num	              {digito}+(\.{digito}+)?(E[+-]?{digito}+)?
estereotipoClasse	  [event|situation|process|category|mixin|phaseMixin|roleMixin|historicalRoleMixin|kind|collective|quantity|quality|mode|intrisicMode|extrinsicMode|subkind|phase|role|historicalRole]
estereotipoRelacao  [material|derivation|comparative|mediation|characterization|externalDependence|componentOf|memberOf|subCollectionOf|subQualityOf|instantiation|termination|participational|participation|historicalDependence|creation|manifestation|bringsAbout|triggers|composition|aggregation|inherence|value|formal|constitution]
reservadas          [genset|disjoint|complete|general|specifics|where|package]