%{
int yylex(void);
int yyparse(void);
void yyerror(const char *s);
%}

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
      | generalizacoes
      | generalizacoes ontology_body
      | declaracao_relacoes
      | declaracao_relacoes ontology_body

package_declaration: 
      | package convencaoIdentificador

classes:
      | classe
      | classe classes

classe:
      | estereotipoClasse convencaoIdentificador
      | estereotipoClasse convencaoIdentificador '{' atributos '}'

atributos:
      | convencaoRelacoes ':' tipoNativo
      | convencaoRelacoes ':' novosTipos
      | convencaoRelacoes ':' tipoNativo '{' metaAtributos '}'
      | convencaoRelacoes ':' novosTipos '{' metaAtributos '}'

relacao_classe:
      | estereotipoClasse convencaoIdentificador estereotipoRelacao convencaoIdentificador

data_types: 
      | datatype convencaoIdentificador '{' atributos '}'

enumerations:
      | enum convencaoIdentificador '{' enum_itens '}'

enum_itens:
      | convencaoInstancias
      | convencaoInstancias ',' enum_itens



%%