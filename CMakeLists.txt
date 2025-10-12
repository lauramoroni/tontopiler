cmake_minimum_required(VERSION 3.10.0)
project(tontopiler)

# --- Configuração do C++ ---
set(CMAKE_BUILD_TYPE Release)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# --- Encontrar Arquivos-Fonte ---
# Procura recursivamente por todos os arquivos .cpp dentro do diretório src/
# e os armazena na variável PROJECT_SOURCES.
file(GLOB_RECURSE PROJECT_SOURCES "src/*.cpp")

# --- Configuração do Flex ---
# É uma boa prática adicionar REQUIRED para falhar se o Flex não for encontrado.
find_package(FLEX REQUIRED)
FLEX_TARGET(Lexer lexer.l ${CMAKE_CURRENT_BINARY_DIR}/lex.yy.cc COMPILE_FLAGS "-+")

# --- Criação do Executável ---
# Adiciona o executável com a saída do Flex e todos os arquivos .cpp de src/
add_executable(tontopiler 
    ${FLEX_Lexer_OUTPUTS} 
    ${PROJECT_SOURCES}
)

# --- Diretórios de Inclusão (Headers) ---
# Adiciona os diretórios onde o compilador deve procurar por arquivos .h.
# É a forma moderna e mais segura de fazer isso, aplicando apenas ao target 'tontopiler'.
target_include_directories(tontopiler PRIVATE
    # Necessário para encontrar o header gerado pelo Flex (ex: lex.yy.h)
    ${CMAKE_CURRENT_BINARY_DIR}
    
    # Necessário para encontrar seus próprios headers em src/
    ${CMAKE_CURRENT_SOURCE_DIR}/src
)