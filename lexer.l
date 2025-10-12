%{
#include <iostream>
#include <fstream>
using namespace std;

enum {
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

char **fileList;
unsigned nFiles;
unsigned currentFile = 0;
bool openFile = false;

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

{estereotipoClasse}       cout << "ESTEREOTIPO_CLASSE: " << yytext << endl;
{estereotipoRelacao}      cout << "ESTEREOTIPO_RELACAO: " << yytext << endl;
{reservadas}              cout << "RESERVADA: " << yytext << endl;
{tipoNativo}              cout << "TIPO_NATIVO: " << yytext << endl;
{metaAtributos}           cout << "META_ATRIBUTO: " << yytext << endl;

{novosTipos}              cout << "NOVO_TIPO: " << yytext << endl;
{convencaoIdentificador}  cout << "CONVENCAO_IDENTIFICADOR: " << yytext << endl;
{convencaoRelacoes}       cout << "CONVENCAO_RELACAO: " << yytext << endl;
{convencaoInstancias}     cout << "CONVENCAO_INSTANCIA: " << yytext << endl;

{num}                     cout << "NUM: " << yytext << endl;

"<"                       cout << "SIMBOLO: " << yytext << endl;
">"                       cout << "SIMBOLO: " << yytext << endl;
"{"                       cout << "SIMBOLO: " << yytext << endl;
"}"                       cout << "SIMBOLO: " << yytext << endl;
"("                       cout << "SIMBOLO: " << yytext << endl;
")"                       cout << "SIMBOLO: " << yytext << endl;
"["                       cout << "SIMBOLO: " << yytext << endl;
"]"                       cout << "SIMBOLO: " << yytext << endl;
"--"                      cout << "SIMBOLO: " << yytext << endl;
"..."                     cout << "SIMBOLO: " << yytext << endl;
"<>--"                    cout << "SIMBOLO: " << yytext << endl;
"--<>"                    cout << "SIMBOLO: " << yytext << endl;
"*"                       cout << "SIMBOLO: " << yytext << endl;
"@"                       cout << "SIMBOLO: " << yytext << endl;
":"                       cout << "SIMBOLO: " << yytext << endl;
";"                       cout << "SIMBOLO: " << yytext << endl;
"<o>--"                   cout << "SIMBOLO: " << yytext << endl;
"--<o>"                   cout << "SIMBOLO: " << yytext << endl;

%%

int main(int argc, char ** argv)
{	
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
}


int yyFlexLexer::yywrap()
{
	// fecha o arquivo processado
	if (openFile)
	{    
		openFile = false;
		fin.close();
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
