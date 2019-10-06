
/* A Bison parser, made by GNU Bison 2.4.1.  */

/* Skeleton interface for Bison's Yacc-like parsers in C
   
      Copyright (C) 1984, 1989, 1990, 2000, 2001, 2002, 2003, 2004, 2005, 2006
   Free Software Foundation, Inc.
   
   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.
   
   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.
   
   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.
   
   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */


/* Tokens.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
   /* Put the tokens into the symbol table, so that GDB and other debuggers
      know about them.  */
   enum yytokentype {
     COMENTARIOS = 258,
     COMENTARIOS_ANIDADOS = 259,
     REPEAT = 260,
     UNTIL = 261,
     OPERACION_SUMA = 262,
     OPERACION_RESTA = 263,
     OPERACION_MULTIPLICACION = 264,
     OPERACION_DIVISION = 265,
     ID = 266,
     ENTERO = 267,
     REAL = 268,
     PARENTESIS_ABIERTO = 269,
     PARENTESIS_CERRADO = 270,
     COMA = 271,
     OPERADOR_ASIGNACION = 272,
     CADENA = 273,
     READ = 274,
     PRINT = 275,
     OPERADOR_IF = 276,
     OPERADOR_THEN = 277,
     OPERADOR_ELSE = 278,
     OPERADOR_ENDIF = 279,
     OPERADOR_AND = 280,
     OPERADOR_OR = 281,
     OPERADOR_NOT = 282,
     OPERADOR_MAYOR_A = 283,
     OPERADOR_MENOR_A = 284,
     OPERADOR_MAYOR_O_IGUAL_A = 285,
     OPERADOR_MENOR_O_IGUAL_A = 286,
     OPERADOR_IGUAL_A = 287,
     OPERADOR_DISTINTO_A = 288,
     VAR = 289,
     ENDVAR = 290,
     DOS_PUNTOS = 291,
     PUNTO_Y_COMA = 292,
     TIPO_ENTERO = 293,
     TIPO_REAL = 294,
     TIPO_CADENA = 295,
     CORCHETE_ABIERTO = 296,
     CORCHETE_CERRADO = 297,
     FILTER = 298,
     GUION_BAJO = 299,
     OPERADOR_ASIG_STRING = 300
   };
#endif
/* Tokens.  */
#define COMENTARIOS 258
#define COMENTARIOS_ANIDADOS 259
#define REPEAT 260
#define UNTIL 261
#define OPERACION_SUMA 262
#define OPERACION_RESTA 263
#define OPERACION_MULTIPLICACION 264
#define OPERACION_DIVISION 265
#define ID 266
#define ENTERO 267
#define REAL 268
#define PARENTESIS_ABIERTO 269
#define PARENTESIS_CERRADO 270
#define COMA 271
#define OPERADOR_ASIGNACION 272
#define CADENA 273
#define READ 274
#define PRINT 275
#define OPERADOR_IF 276
#define OPERADOR_THEN 277
#define OPERADOR_ELSE 278
#define OPERADOR_ENDIF 279
#define OPERADOR_AND 280
#define OPERADOR_OR 281
#define OPERADOR_NOT 282
#define OPERADOR_MAYOR_A 283
#define OPERADOR_MENOR_A 284
#define OPERADOR_MAYOR_O_IGUAL_A 285
#define OPERADOR_MENOR_O_IGUAL_A 286
#define OPERADOR_IGUAL_A 287
#define OPERADOR_DISTINTO_A 288
#define VAR 289
#define ENDVAR 290
#define DOS_PUNTOS 291
#define PUNTO_Y_COMA 292
#define TIPO_ENTERO 293
#define TIPO_REAL 294
#define TIPO_CADENA 295
#define CORCHETE_ABIERTO 296
#define CORCHETE_CERRADO 297
#define FILTER 298
#define GUION_BAJO 299
#define OPERADOR_ASIG_STRING 300




#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef union YYSTYPE
{

/* Line 1676 of yacc.c  */
#line 123 "sintactico.y"

	int int_val;
	double float_val;
	char *str_val;



/* Line 1676 of yacc.c  */
#line 150 "y.tab.h"
} YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define yystype YYSTYPE /* obsolescent; will be withdrawn */
# define YYSTYPE_IS_DECLARED 1
#endif

extern YYSTYPE yylval;


