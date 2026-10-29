flex lexer.l
bison parserTyPyoCa.y -o y.tab.c -d -v -g
gcc lex.yy.c y.tab.c -o TyPyoCompiler