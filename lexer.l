%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "y.tab.h" /* Inclui a definicao dos tokens gerados pelo Yacc */

/* Estrutura para lidar com a indentação */
#define MAX_INDENT 100
int indent_stack[MAX_INDENT] = {0};
int indent_top = 0;
int current_line_indent = 0;
%}

/* Habilita a contagem de linhas automatica para o yyerror no Yacc */
%option yylineno
/* Desabilita o yywrap, ja que estamos tratando o fim de arquivo na regra <<EOF>> */
%option noyywrap

/* Regras auxiliares */
DIGIT    [0-9]
ID       [a-zA-Z_][a-zA-Z0-9_]*
STRING   \"([^\\\"]|\\.)*\"
REAL_NUM {DIGIT}+"."{DIGIT}+

%%

 /* Início de uma nova linha: conta espaços para gerenciar INDENT/DEDENT */
^[ \t]*    {
                current_line_indent = yyleng;
                if (current_line_indent > indent_stack[indent_top]) {
                    indent_stack[++indent_top] = current_line_indent;
                    printf("INDENT\n");
                    return INDENT;
                } else if (current_line_indent < indent_stack[indent_top]) {
                    while (indent_top > 0 && current_line_indent < indent_stack[indent_top]) {
                        indent_top--;
                        printf("DEDENT\n");
                        return DEDENT;
                    }
                }
           }

 /* Ignora espaços e tabs no meio da linha */
[ \t]+     ;

 /* Palavras-chave de Estrutura */
"main"     { return MAIN; }
"endmain"  { return ENDMAIN; }
"sub"      { return SUB; }
"endsub"   { return ENDSUB; }
"while"    { return WHILE; }
"endwhile" { return ENDWHILE; }
"if"       { return IF; }
"endif"    { return ENDIF; }
"return"   { return RETURN; }

 /* Palavras-chave de Tipos de Dados */
"int"      { return INT; }

 /* Nota: Estes tipos nao estao no seu arquivo Yacc atual. 
    Se for usa-los, lembre-se de declarar %token no Yacc. */
"real"     { /* return REAL; */ } 
"string"   { /* return STRING_TYPE; */ }
"bool"     { /* return BOOL; */ }
"true"     { /* return TRUE; */ }
"false"    { /* return FALSE; */ }

 /* Símbolos e Operadores */
"("        { return LPAREN; }
")"        { return RPAREN; }
"["        { return LBRACKET; }
"]"        { return RBRACKET; }
","        { return COMMA; }
"+"        { return PLUS; }
"-"        { return MINUS; }
"*"        { return MUL; }
"/"        { return DIV; }
"<="       { return LEQ; }
">="       { return GEQ; }
"=="       { return EQ; }
"!="       { return NEQ; }
"<"        { return LT; }
">"        { return GT; }
"="        { return ASSIGN; }

 /* Literais e Identificadores (Sintaxe corrigida) */
{REAL_NUM} { return NUM; } /* Mapeado para NUM para ser compativel com o Yacc atual */
{DIGIT}+   { return NUM; }
{STRING}   { return STRING_LITERAL; }
{ID}       { return ID; }

 /* Nova Linha */
\n|\r\n    { return NEWLINE; }

 /* Caractere Invalido */
.          { printf("Erro lexico: Caractere invalido '%s'\n", yytext); }

 /* Tratamento do Fim de Arquivo (Emite DEDENTs remanescentes) */
<<EOF>>    { 
                if (indent_top > 0) {
                    indent_top--;
                    printf("DEDENT\n");
                    return DEDENT;
                }
                yyterminate(); 
           }

%%