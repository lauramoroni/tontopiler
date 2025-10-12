#ifndef TOKEN_H
#define TOKEN_H

enum TokenType {
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

inline const char* tokenToString(int token) {
    switch (token) {
        case NUM:                   return "NUM";
        case ESTEREOTIPO_CLASSES:   return "ESTEREOTIPO_CLASSES";
        case ESTEREOTIPO_RELACOES:  return "ESTEREOTIPO_RELACOES";
        case RESERVADAS:            return "RESERVADAS";
        case SIMBOLOS:              return "SIMBOLOS";
        case CONVENCAO_CLASSES:     return "CONVENCAO_CLASSES";
        case CONVENCAO_RELACOES:    return "CONVENCAO_RELACOES";
        case CONVENCAO_INSTANCIAS:  return "CONVENCAO_INSTANCIAS";
        case TIPOS_NATIVOS:         return "TIPOS_NATIVOS";
        case NOVOS_TIPOS:           return "NOVOS_TIPOS";
        case META_ATRIBUTOS:        return "META_ATRIBUTOS";
        default:                    return "TOKEN_DESCONHECIDO";
    }
}

#endif