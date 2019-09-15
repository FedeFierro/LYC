%{
#include <stdio.h>
#include <stdlib.h>
#include <conio.h>
#include "y.tab.h"
#include <string.h>
int yystopparser=0;
FILE  *yyin;
char *yyltext;
char *yytext;



/* --------------- CONSTANTES --------------- */
#define TAM_NOMBRE 32	/* Limite tamaño nombre (sumar 1 para _ ) */
#define CteString "CTE_STRING"

/* --------------- PROTOTIPO DE FUNCIONES PRIMERA ENTREGA --------------- */

int yylex();
int yyerror();

void mostrarError(char *mensaje);

%}

%union {
int int_val;
double float_val;
char *str_val;
}

%start start_programa

%token COMENTARIOS 
COMENTARIOS_ANIDADOS 
REPEAT 
UNTIL
OPERACION_SUMA
OPERACION_RESTA
OPERACION_MULTIPLICACION
OPERACION_DIVISION
ID
ENTERO
REAL
PARENTESIS_ABIERTO
PARENTESIS_CERRADO
COMA
OPERADOR_ASIGNACION
CADENA
READ
WRITE
OPERADOR_IF 
OPERADOR_ELSE
OPERADOR_ENDIF
OPERADOR_AND
OPERADOR_OR
OPERADOR_NOT
OPERADOR_MAYOR_A
OPERADOR_MENOR_A
OPERADOR_MAYOR_O_IGUAL_A
OPERADOR_MENOR_O_IGUAL_A
OPERADOR_IGUAL_A
OPERADOR_DISTINTO_A
VAR
ENDVAR
DOS_PUNTOS
PUNTO_Y_COMA
TIPO_ENTERO
TIPO_REAL
TIPO_CADENA
CORCHETE_ABIERTO
CORCHETE_CERRADO
FILTER
GUION_BAJO

%%

start_programa : programa 
		{ printf("Compilacion exitosa\n\n"); };

programa : bloque_declaracion  bloque_programa
		{ printf("Programa OK\n\n"); };

bloque_declaracion: VAR lista_definiciones ENDVAR 
		{  
			printf("bloque_definiciones OK\n\n");
		};

lista_definiciones: lista_definiciones definicion {	printf("lista_definiciones -> lista_definiciones definicion OK\n\n");} 
					| definicion {	printf("lista_definiciones -> definicion OK\n\n");}

definicion: CORCHETE_ABIERTO lista_tipo_dato CORCHETE_CERRADO DOS_PUNTOS CORCHETE_ABIERTO lista_ids CORCHETE_CERRADO 
		{	finDeclaracion();  
			printf("definicion OK\n\n");};

lista_tipo_dato: lista_tipo_dato COMA tipo_dato	{ printf("lista_tipo_dato -> lista_tipo_dato , tipo_dato OK\n\n");} 
					| tipo_dato {printf("lista_tipo_dato -> tipo_dato OK \n\n");}

tipo_dato: 
  TIPO_ENTERO 
  | TIPO_REAL 
  | TIPO_CADENA

lista_ids: 
  lista_ids COMA ID {printf("lista_IDs -> lista_IDs , ID\n\n");}
  | ID	{printf("lista_IDs -> ID OK \n\n");}

	
bloque_programa : bloque_programa sentencia {printf("bloque_programa -> bloque_programa sentencia OK \n\n");}
				| sentencia {printf("bloque_programa -> sentencia OK \n\n");}

sentencia : asignacion 	{printf("sentencia -> asignacion OK \n\n");}
			| bloque_condicional	{printf("sentencia -> bloque_condicional OK \n\n");} 
			| asignacion_multiple 	{printf("sentencia -> asignacion_multiple OK \n\n");}
			| bloque_iteracion 		{printf("sentencia -> bloque_iteracion OK \n\n");}
			| entrada_datos			{printf("sentencia -> entrada_datos OK \n\n");}
			| salida_datos			{printf("sentencia -> salida_datos OK \n\n");}
					
entrada_datos: READ ID	{printf("READ ID OK \n\n");}

salida_datos: WRITE CADENA {printf("WRITE CADENA OK \n\n");}

bloque_iteracion: REPEAT bloque_programa UNTIL condicion {printf("bloque REPEAT-UNTIL\n\n");}

asignacion: ID OPERADOR_ASIGNACION expresion PUNTO_Y_COMA	{printf("asignacion OK\n\n");}

expresion:  expresion OPERACION_SUMA termino	{printf("expresion -> exp + term OK \n\n");} 
			| expresion OPERACION_RESTA termino 	{printf("expresion -> exp - term OK \n\n");}
			| termino							{printf("expresion -> term OK \n\n");}

termino: termino OPERACION_MULTIPLICACION factor {printf("term -> term * factor OK \n\n");} 
		| termino OPERACION_DIVISION factor 	{printf("term -> term / factor OK \n\n");}
		| factor			{printf("term -> factor OK \n\n");}

factor: ID
		| ENTERO
		| REAL
		| CADENA
		| PARENTESIS_ABIERTO expresion PARENTESIS_CERRADO
		| filtro
		
bloque_condicional: bloque_if {printf("bloque_condicional\n");}

bloque_if: OPERADOR_IF condicion bloque_programa OPERADOR_ENDIF 
		| OPERADOR_IF condicion  bloque_programa OPERADOR_ELSE bloque_programa OPERADOR_ENDIF 

condicion : PARENTESIS_ABIERTO comparacion OPERADOR_AND comparacion PARENTESIS_CERRADO 
			| PARENTESIS_ABIERTO comparacion OPERADOR_OR comparacion PARENTESIS_CERRADO
			| PARENTESIS_ABIERTO OPERADOR_NOT PARENTESIS_ABIERTO comparacion PARENTESIS_CERRADO PARENTESIS_CERRADO 
			| PARENTESIS_ABIERTO comparacion PARENTESIS_CERRADO 		// condicion simple
			
comparacion : expresion OPERADOR_MAYOR_A expresion	
			| expresion OPERADOR_MENOR_A expresion
			| expresion OPERADOR_MAYOR_O_IGUAL_A expresion
			| expresion OPERADOR_MENOR_O_IGUAL_A expresion
			| expresion OPERADOR_IGUAL_A expresion
			| expresion OPERADOR_DISTINTO_A expresion
			
filtro: FILTER PARENTESIS_ABIERTO condicion_filter COMA  CORCHETE_ABIERTO lista_ids CORCHETE_CERRADO PARENTESIS_CERRADO 
				{printf("FILTER OK\n\n");}

condicion_filter: comparacion_filter OPERADOR_AND comparacion_filter 
				| comparacion_filter OPERADOR_OR comparacion_filter
				| OPERADOR_NOT  PARENTESIS_ABIERTO comparacion_filter PARENTESIS_CERRADO
				| comparacion_filter
				
comparacion_filter : GUION_BAJO OPERADOR_MAYOR_A expresion_numerica	
					| GUION_BAJO OPERADOR_MENOR_A expresion_numerica
					| GUION_BAJO OPERADOR_MAYOR_O_IGUAL_A expresion_numerica
					| GUION_BAJO OPERADOR_MENOR_O_IGUAL_A expresion_numerica
					| GUION_BAJO OPERADOR_IGUAL_A expresion_numerica
					| GUION_BAJO OPERADOR_DISTINTO_A expresion_numerica

				
asignacion_multiple: CORCHETE_ABIERTO lista_ids CORCHETE_CERRADO OPERADOR_ASIGNACION CORCHETE_ABIERTO lista_expresiones CORCHETE_CERRADO 
		{printf("hay una asignacion multiple OK \n\n");}
 
lista_expresiones : lista_expresiones COMA expresion_numerica
				| expresion_numerica


expresion_numerica: expresion_numerica OPERACION_SUMA termino_numerico	{printf("expresion_numerica -> exp + term OK \n\n");} 
			| expresion_numerica OPERACION_RESTA termino_numerico 	{printf("expresion_numerica -> exp - term OK \n\n");}
			| termino_numerico							{printf("expresion_numerica -> term OK \n\n");}

termino_numerico: termino_numerico OPERACION_MULTIPLICACION factor_numerico {printf("term_num -> term_num * factor_numerico OK \n\n");} 
		| termino_numerico OPERACION_DIVISION factor_numerico 	{printf("term_num -> term / factor_numerico OK \n\n");}
		| factor_numerico			{printf("term_num-> factor_numerico OK \n\n");}

factor_numerico: ID
		| ENTERO
		| REAL
		| PARENTESIS_ABIERTO expresion_numerica PARENTESIS_CERRADO
		| filtro


%%

int main(int argc,char *argv[]){
	if ((yyin = fopen(argv[1], "rt")) == NULL){
		printf("\nNo se puede abrir el archivo: %s\n", argv[1]);
	}else {
		yyparse();
		guardarTabla();
	}
	fclose(yyin);
	return 0;
}


void mostrarError(char *mensaje) {
  printf("%s\n", mensaje);
  yyerror();
}

int yyerror(void){
    printf("ERROR EN COMPILACION.\n");
    system ("Pause");
    exit (1);
}

