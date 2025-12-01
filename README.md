# Sumário

- [Tontopiler](#tontopiler)
- [Tonto](#tonto)
- [Funcionalidades](#funcionalidades)
- [Ferramentas Utilizadas](#ferramentas-utilizadas)
- [Instalação](#instalação)
- [Como Usar](#como-usar)
  - [Contador de Construtos](#contador-de-construtos)
  - [Consultar Lexemas](#consultar-lexemas)
  - [Tabela de Símbolos](#tabela-de-símbolos)
- [Colaboradores](#colaboradores)

# Tontopiler

O Tontopiler é um compilador desenvolvido em C++ para a linguagem Tonto (Textual Ontology Language). Este projeto implementa a primeira fase do processo de compilação, a análise léxica, para a linguagem de ontologia Tonto.

## Tonto

[Tonto](https://github.com/matheuslenke/Tonto), um acrônimo para Textual Ontology Language, é uma linguagem que permite a especificação textual de ontologias como artefatos computacionais. Ontologias são grafos de conhecimento que estabelecem relações de sentido entre conceitos e são, em geral, especificadas em linguagens lógicas como RDF (Resource Description Framework) ou OWL (Web Ontology Language). Elas são fundamentais para a Web 3.0 (ou Web Semântica), onde cada nó do grafo corresponde a um recurso na Web identificado por um URI (Uniform Resource Identifier).

A linguagem Tonto foi proposta para simplificar a modelagem de ontologias, permitindo que especialistas de diversas áreas possam construir modelos computacionais com significado mais profundo. 

## Funcionalidades

O Tontopiler realiza a análise léxica e sintática de uma ontologia especificada em Tonto. O analisador oferece:

  * **Verificação Sintática:** Valida se a estrutura do código segue a gramática da linguagem Tonto.
  * **Relatório de Erros:** Indica erros léxicos e sintáticos, apontando a linha e o token esperado.
  * **Visão analítica:** Exibe todos os tokens reconhecidos e suas propriedades.
  * **Tabela de síntese:** Apresenta um resumo quantitativo dos elementos da linguagem (Contador de Construtos).

Além disso, o analisador gera uma tabela de símbolos detalhada contendo lexemas, tokens, ocorrências e posições.

## Ferramentas Utilizadas

Lista das ferramentas principais usadas no projeto, com as versões detectadas no ambiente de desenvolvimento onde este repositório foi testado:

- **C++** (g++): 13.3.0 — Linguagem de programação principal do projeto.
- **Flex**: 2.6.4 — Ferramenta para geração de analisadores léxicos.
- **Bison**: 3.8.2 — Ferramenta para geração de analisadores sintáticos.
- **Ncurses** (ncurses-config): 6.4.20240113 — Biblioteca para a criação de interfaces de usuário em modo texto (TUI).
- **CMake**: 3.28.3 — Sistema de automação de compilação.
- **Make**: GNU Make 4.3
- **git**: 2.43.0

## Instalação

Para compilar e executar o projeto, siga os passos abaixo:

1.  **Instale a ferramentas necessárias:**

    - No Ubuntu/Debian:

      ```bash
      sudo apt-get update
      sudo apt-get install build-essential cmake flex bison libncurses5-dev
      ```

    - No Fedora:

      ```bash
      sudo dnf install @development-tools cmake flex bison ncurses-devel
      ```

2.  **Clone o repositório:**

    ```bash
    git clone https://github.com/lauramoroni/tontopiler.git
    cd tontopiler
    ```

3.  **Execute o CMake e o Make:**

    ```bash
    cd build/
    cmake ..
    make
    ```

## Como Usar

Após a compilação, um executável chamado `tontopiler` será criado no diretório `build`. Para executá-lo, utilize o seguinte comando:

```bash
./tontopiler
```

O programa iniciará uma interface de usuário em modo texto (TUI). No menu inicial, selecione **"Syntax Analysis"** para começar.

Você poderá navegar pelos diretórios e selecionar um arquivo `.tonto` para análise.

![Tontopiler TUI](docs/tontopiler_tui.png)

O Tontopiler realizará a análise sintática. Se houver erros, eles serão exibidos na tela. Caso contrário, o status será de sucesso e a tabela de símbolos será gerada no arquivo `symbol_table.tsv`.

![Syntax Analysis Success Status](docs/syntax_analysis_success_status.png)

Caso a análise falhe, uma mensagem de erro será exibida indicando a linha e o token esperado.

![Syntax Analysis Error Status](docs/syntax_analysis_error_status.png)

Após a análise, o menu de resultados será exibido com as seguintes opções:

![Analysis Menu](docs/analysis_menu.png)

### Contador de Construtos

Exibe um resumo dos construtos da linguagem (Classes, Relações, Pacotes, etc.) identificados no arquivo analisado.

![Construct Counter](docs/construct_counter.png)

### Consultar Lexemas

Permite consultar lexemas específicos na tabela de símbolos, exibindo detalhes como token, ocorrências, posições (linha, coluna) e construto associado.

![Lexeme Query](docs/lexeme_query.png)

### Tabela de Símbolos

Exibe a tabela de símbolos completa gerada a partir da análise. O arquivo `symbol_table.tsv` também é salvo no disco contendo:
- Lexeme: O lexema reconhecido.
- Token: O tipo de token associado.
- Occurrences: O número de vezes que aparece.
- Positions: As coordenadas (linha, coluna).
- Construct: O tipo de construto gramatical (se aplicável).
- Relationships: Relações identificadas.

![Symbol Table TSV](docs/symbol_table_tsv.gif)

# Análise Léxica
## O que é o Flex?
[Flex](https://westes.github.io/flex/manual/) (Fast Lexical Analyzer Generator) é uma ferramenta de código aberto utilizada para gerar analisadores léxicos, também conhecidos como scanners ou tokenizers. A partir de um arquivo de entrada com especificações de padrões (expressões regulares) e ações correspondentes em código C, o Flex gera um arquivo de código-fonte em C que implementa o analisador léxico. Este analisador é capaz de reconhecer padrões em um texto de entrada e dividi-lo em uma sequência de tokens, que são as unidades léxicas fundamentais de uma linguagem de programação.

## Como Funciona a Análise Léxica?
A análise léxica é a primeira fase de um compilador. O analisador léxico, lê o código-fonte como uma sequência de caracteres e a transforma em uma sequência de **tokens**. Cada token representa uma unidade lexicalmente significativa da linguagem, como palavras-chave, identificadores, operadores, números e símbolos.

O processo envolve as seguintes etapas:

- Leitura do código-fonte: O analisador lê o código-fonte caractere por caractere.

- Reconhecimento de padrões: Utilizando **expressões regulares**, o analisador identifica sequências de caracteres que correspondem aos padrões dos tokens da linguagem.

- Geração de tokens: Para cada padrão reconhecido (lexema), o analisador léxico gera um token correspondente.

- Descarte de irrelevantes: Espaços em branco, comentários e outros elementos que não fazem parte da estrutura da linguagem são geralmente ignorados.

- Tabela de símbolos: O analisador léxico interage com uma tabela de símbolos para armazenar informações sobre os identificadores encontrados no código.

A saída da análise léxica é uma sequência de tokens que será utilizada pela próxima fase do compilador, a análise sintática.

## Definição dos Construtos para a Linguagem Tonto
Seguindo a estrutura do Flex, os construtos da linguagem Tonto foram definidos no arquivo `lexer.l` utilizando expressões regulares.

- Estereótipos de Classe (**ESTEREOTIPO_CLASSES**): Foram definidos listando todas as palavras-chave que representam estereótipos de classe.

- Palavras Reservadas (**RESERVADAS**): Palavras como genset, disjoint, complete, general, specifics e package.

- Nomes de Classes (**convencaoIdentificador**): Devem começar com uma letra maiúscula, seguida por letras ou sublinhados. Por exemplo: Person, Living_Person.

- Nomes de Relações (**convencaoRelacoes**): Devem começar com uma letra minúscula.

- Nomes de Instâncias (**convencaoInstancias**): Podem começar com qualquer letra e devem terminar com um número.

- Símbolos Especiais (**SIMBOLOS**): Símbolos como `{`, `}`, `(`, `)`, `[`, `]`, `,` e `...`.

- Tratamento de Erros (**TOKEN_DESCONHECIDO**): Qualquer caractere ou sequência de caracteres que não se encaixe em nenhum dos padrões definidos é tratado como um erro léxico.

Cada vez que um padrão é reconhecido, o lexema correspondente é inserido na tabela de símbolos, juntamente com o seu tipo de token, número da linha e coluna onde foi encontrado.

# Análise Sintática

## Como funciona a Análise Sintática?
A análise sintática é a segunda fase do processo de compilação. Enquanto a análise léxica identifica os tokens individuais, a análise sintática verifica se a sequência desses tokens forma sentenças válidas de acordo com a gramática da linguagem Tonto.

O Tontopiler utiliza o **Bison**, um gerador de analisadores sintáticos, para esta tarefa. O analisador sintático (parser) recebe os tokens do analisador léxico e tenta construir uma estrutura gramatical (árvore de derivação). Se a sequência de tokens não corresponder a nenhuma regra da gramática, um erro sintático é reportado.

## Definição das gramáticas
As regras gramaticais da linguagem Tonto foram definidas no arquivo `parser.y`. Abaixo estão as principais estruturas reconhecidas:

- **Ontologia**: A raiz da gramática. Uma ontologia pode conter declarações de pacotes e um corpo com diversos elementos.
- **Declaração de Pacotes e Importações**: Define o escopo da ontologia (`package`) ou importa outras ontologias (`import`).
- **Classes**: Definidas por estereótipos (ex: `kind`, `subkind`) seguidos de um identificador. Podem conter atributos com tipos nativos ou personalizados.
- **Relações**: Podem ser definidas dentro de classes ou separadamente. Incluem estereótipos de relação, cardinalidades (ex: `[1..*]`) e a direção da relação.
- **Generalizações**: Estruturas que definem hierarquias entre classes, utilizando palavras-chave como `genset`, `general`, `specifics`.
- **Tipos de Dados e Enumerações**: Definições de novos tipos (`datatype`) e listas de valores permitidos (`enum`).

O analisador trata erros sintáticos informando a linha e o lexema onde a falha ocorreu, e quando possível, o token que era esperado.

## Colaboradores

- [Laura Moroni](https://github.com/lauramoroni)
- [Paulo Andrade](https://github.com/andrade-paulo)
