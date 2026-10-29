%{
#include <stdio.h>

int yylex(void);
int yyerror(char *s);
extern int yylineno;
extern char * yytext;

%}

%token MAIN LPAREN RPAREN NEWLINE INDENT DEDENT ENDMAIN SUB ENDSUB COMMA
%token ASSIGN RETURN IF ENDIF WHILE ENDWHILE INT LBRACKET RBRACKET
%token  LT LEQ GT GEQ EQ NEQ NUM STRING_LITERAL PLUS MINUS MUL DIV ID

%start programa

%%
programa : declaracoes_globais {} 
	;

declaracoes_globais : declaracoes_globais declaracao {}
		| declaracao                                 {}
	    ;

declaracao : subrotina {}
	| main_block       {}
	;
	
main_block : MAIN LPAREN RPAREN NEWLINE INDENT comandos DEDENT ENDMAIN NEWLINE {}
	;

subrotina : SUB tipo_opt ID LPAREN parametros_opt RPAREN NEWLINE INDENT comandos DEDENT ENDSUB NEWLINE {}
	;

tipo_opt
    : tipo {}
    | /* vazio */
    ;

parametros_opt
    : lista_parametros {}
    | /* vazio */
    ;

lista_parametros
    : lista_parametros COMMA tipo ID {}
    | tipo ID {}
    ;

comandos
    : comandos comando NEWLINE {}
    | comando NEWLINE {}
    | /* vazio */
    ;

comando
    : declaracaovar {}
    | atribuicao    {}
    | comandoif     {}
    | comandowhile  {}
    | chamadafuncao {}
    | retorno       {}
    ;

declaracaovar
    : tipo ID ASSIGN expressao {}
    ;

atribuicao
    : l_value ASSIGN expressao {}
    ;

comandowhile
    : WHILE LPAREN expressao RPAREN NEWLINE INDENT comandos DEDENT ENDWHILE NEWLINE {}
    ;

comandoif
    : IF LPAREN expressao RPAREN NEWLINE INDENT comandos DEDENT ENDIF NEWLINE {}
    ;

retorno
    : RETURN expressao {}
    ;

chamadafuncao
    : ID LPAREN argumentos_opt RPAREN {}
    ;

argumentos_opt
    : lista_argumentos {}
    | /* vazio */
    ;

lista_argumentos
    : lista_argumentos COMMA expressao {}
    | expressao                        {}
    ;

tipo
    : INT brackets_opt {}
    ;

brackets_opt
    : brackets_opt LBRACKET RBRACKET {}
    | /* vazio */
    ;

expressao
    : exprelacional {}
    ;

exprelacional
    : exparitimetica op_relacional exparitimetica {}
    | exparitimetica                              {}
    ;

op_relacional
    : LT | LEQ | GT | GEQ | EQ | NEQ {}
    ;

exparitimetica
    : exparitimetica PLUS termo  {}
    | exparitimetica MINUS termo {}
    | termo                      {}
    ;

termo
    : termo MUL fator {}
    | termo DIV fator {}
    | fator           {}
    ;

l_value
    : ID l_value_brackets {}
    ;

l_value_brackets
    : l_value_brackets LBRACKET expressao RBRACKET {}
    | /* vazio */                                  {}
    ;

fator
    : chamadafuncao           {}
    | l_value                 {}
    | NUM                     {}
    | STRING_LITERAL          {}
    | arrayLiteral            {}
    | LPAREN expressao RPAREN {}
    ;

arrayLiteral
    : LBRACKET array_elements_opt RBRACKET {}
    ;

array_elements_opt
    : lista_argumentos {}
    | /* vazio */      {}
    ;

%%

int main (void) {
	return yyparse ( );
}

int yyerror (char *msg) {
	fprintf (stderr, "%d: %s at '%s'\n", yylineno, msg, yytext);
	return 0;
}