c:\GnuWin32\bin\flex lexico.l
c:\GnuWin32\bin\bison -dyv sintactico.y
c:\MinGW\bin\gcc.exe lex.yy.c y.tab.c -o execute.exe
pause
execute.exe prueba.txt
del lex.yy.c
del y.tab.c
del y.output
del y.tab.h
del execute.exe
pause