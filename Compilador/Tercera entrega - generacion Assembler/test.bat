flex lexico.l
bison -dyv sintactico.y
gcc.exe lex.yy.c y.tab.c pila.c pila.h -o grupo01.exe
pause
grupo01.exe prueba.txt
del lex.yy.c
del y.tab.c
del y.output
del y.tab.h
del grupo01.exe
pause