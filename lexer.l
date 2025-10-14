%{
#include <iostream>
#include <fstream>
#include "SymbolTable.h"
#include "token.h"

using namespace std;

char **fileList;
unsigned nFiles;
unsigned currentFile = 0;
bool openFile = false;
bool hasError = false;

SymbolTable symbolTable = SymbolTable();

ifstream fin;
%}

delim	                  [ \s\t\n]
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

convencaoIdentificador    {maiuscula}{letra}*(_{letra}+)*
convencaoRelacoes         {minuscula}{letra}*(_{letra}+)*
convencaoInstancias       {letra}+_*{letra}*{digito}+
novosTipos                {letra}+DataType


%% 
{brancos}	              ;

{estereotipoClasse}       symbolTable.insert(yytext, ESTEREOTIPO_CLASSES);
{estereotipoRelacao}      symbolTable.insert(yytext, ESTEREOTIPO_RELACOES);
{reservadas}              symbolTable.insert(yytext, RESERVADAS);
{tipoNativo}              symbolTable.insert(yytext, TIPOS_NATIVOS);
{metaAtributos}           symbolTable.insert(yytext, META_ATRIBUTOS);

{novosTipos}              symbolTable.insert(yytext, NOVOS_TIPOS);
{convencaoIdentificador}  symbolTable.insert(yytext, CONVENCAO_CLASSES);
{convencaoRelacoes}       symbolTable.insert(yytext, CONVENCAO_RELACOES);
{convencaoInstancias}     symbolTable.insert(yytext, CONVENCAO_INSTANCIAS);

{num}                     symbolTable.insert(yytext, NUM);

"<"                       symbolTable.insert(yytext, SIMBOLOS);
">"                       symbolTable.insert(yytext, SIMBOLOS);
"{"                       symbolTable.insert(yytext, SIMBOLOS);
"}"                       symbolTable.insert(yytext, SIMBOLOS);
"("                       symbolTable.insert(yytext, SIMBOLOS);
")"                       symbolTable.insert(yytext, SIMBOLOS);
"["                       symbolTable.insert(yytext, SIMBOLOS);
"]"                       symbolTable.insert(yytext, SIMBOLOS);
"-"                       symbolTable.insert(yytext, SIMBOLOS);
"--"                      symbolTable.insert(yytext, SIMBOLOS);
"..."                     symbolTable.insert(yytext, SIMBOLOS);
"<>--"                    symbolTable.insert(yytext, SIMBOLOS);
"--<>"                    symbolTable.insert(yytext, SIMBOLOS);
"*"                       symbolTable.insert(yytext, SIMBOLOS);
"@"                       symbolTable.insert(yytext, SIMBOLOS);
":"                       symbolTable.insert(yytext, SIMBOLOS);
";"                       symbolTable.insert(yytext, SIMBOLOS);
","                       symbolTable.insert(yytext, SIMBOLOS);
"<o>--"                   symbolTable.insert(yytext, SIMBOLOS);
"--<o>"                   symbolTable.insert(yytext, SIMBOLOS);

.                         { 
                           symbolTable.insert(yytext, TOKEN_DESCONHECIDO);
                           cerr << "Erro Léxico: Caractere inesperado '" << yytext 
                                 << "' na linha " << yylineno << endl;
							      hasError = true;
                          }


%%

int main(int argc, char ** argv)
{	

	if (argc < 2) 
	{
		cerr << "Erro: Nenhum arquivo de entrada foi fornecido.\n";
		cerr << "Uso: " << argv[0] << " <arquivo1> [<arquivo2> ... <arquivoN>]\n";
		return 1;
	}

   nFiles = argc - 1;  	     // quantidade de arquivos
   fileList = argv + 1;         // nomes dos arquivos
	
	yyFlexLexer lexer;
    lexer.switch_streams(&fin);
	lexer.yywrap();

	if (openFile)
	{
        cout << "-=-=-=- Analisador Léxico -=-=-=-\n\n";
		lexer.yylex();
	}

	if (hasError)
	{
		cout << "\nAnálise Léxica finalizada com erros.\n";
		return 1;
	}
	else
	{
		cout << "\nAnálise Léxica finalizada sem erros.\n";
		return 0;
	}
}


int yyFlexLexer::yywrap()
{
	// fecha o arquivo processado
	if (openFile)
	{    
		openFile = false;
		fin.close();

		cout << "Exporting Symbol Table\n";
		symbolTable.toTSV("symbol_table.tsv");
	}

	// enquanto existir arquivos para processar, tentar abrir o próximo
	while (!openFile && (fileList[currentFile] != nullptr)) 
    {
		fin.open(fileList[currentFile++]);
		if (fin.is_open()) 
        {
			openFile = true;
		}
		else
		{
			cout << fileList[currentFile-1] << " = não foi possível abrir\n";
		}		
	}

	return (openFile ? 0 : 1);	// 0 significa que tem mais entrada para processar
}
