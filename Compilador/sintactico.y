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
FILE *archivoTablaDeSimbolos;
FILE *archivoCodigoIntermedio;

int cantidadTokens = 0;
int cant_variables=0;
int i=0;
int max=0;
int min=0;

// TABLA SIMBOLOS
typedef struct
{
    char nombre[100];
    char tipo  [11];
    char valor [100];
    int longitud;
} struct_tabla_de_simbolos;

typedef struct
{
  char tipo [11];
  char valor [100]; 
} struct_almacenar_id;

struct_tabla_de_simbolos tablaDeSimbolos[200];
struct_almacenar_id vectorAlmacenamiento[10];

char tipoVariableActual[20];

void copiarCharEn(char **, char*);
char* operadorAux;
char* idAux;

int yylex();
int yyerror();
int cant_tipo_variable =0;

void mostrarError(char *mensaje);
void guardarTipo(char * tipoVariable);
int existeCadenaEnTablaDeSimbolos(char* valor);
int existeTokenEnTablaDeSimbolos(char* nombre);
void guardarTablaDeSimbolos();
void guardarEnteroEnTablaDeSimbolos(int token);
void guardarCadenaEnTablaDeSimbolos(char* token);
void guardarIDEnTablaDeSimbolos(char* token);
void guardarRealEnTablaDeSimbolos(double token);
char* buscarCadenaEnTablaDeSimbolos(char *valor);
void guardarEnVectorAlmacenamiento(int opc, char * cad);
void ignorarNodeclaradas();

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
OPERADOR_ENTRADA
OPERADOR_SALIDA
OPERADOR_IF 
ELSE
ENDIF
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
  {
    printf("Compilacion exitosa\n");
  };

programa : bloque_declaracion  bloque_programa
  {
    printf("Programa OK\n");
  };

bloque_declaracion: VAR lista_definiciones ENDVAR {ignorarNodeclaradas(); printf("bloque_definiciones OK\n");};

lista_definiciones: lista_definiciones definicion {printf("lista_definiciones definicion OK\n");} | definicion {printf("lista_definiciones->definicion OK\n");}

definicion: CORCHETE_ABIERTO lista_tipo_dato CORCHETE_CERRADO DOS_PUNTOS CORCHETE_ABIERTO lista_ids CORCHETE_CERRADO {printf("definicion OK\n");};

tipo_dato: 
  TIPO_ENTERO       
    {
      guardarTipo("ENTERO");
      guardarEnVectorAlmacenamiento(1,tipoVariableActual);
      printf("TIPO_ENTERO en tipo_variable OK\n");
    }
  | TIPO_REAL 
    {
      guardarTipo("REAL");
      guardarEnVectorAlmacenamiento(1,tipoVariableActual);
      printf("TIPO_REAL en tipo_variable OK\n");
    }
  | TIPO_CADENA
    {
      guardarTipo("CADENA");
      guardarEnVectorAlmacenamiento(1,tipoVariableActual);
      printf("TIPO_CADENA en tipo_variable OK\n");
    }

lista_tipo_dato: lista_tipo_dato COMA tipo_dato | tipo_dato

lista_ids: 
  lista_ids COMA ID 
    {
      printf("%s\n", yylval.str_val);
      guardarEnVectorAlmacenamiento(2,yylval.str_val);
      //guardarIDEnTablaDeSimbolos(yylval.str_val);
      printf("ID en lista_ids OK\n");
    }
  | ID
    {
      printf("%s\n", yylval.str_val);
      //guardarIDEnTablaDeSimbolos(yylval.str_val);
      guardarEnVectorAlmacenamiento(2,yylval.str_val);
      printf("ID en lista_ids OK\n");
    }

	| lista_ids COMA CADENA{guardarEnVectorAlmacenamiento(2,yylval.str_val); printf("lista_ids -> lista_ids COMA UNA CADENA\n , cadena: %s\n", yylval.str_val);}
	
	| CADENA{guardarEnVectorAlmacenamiento(2,yylval.str_val);	printf("reconoci una cadena: %s\n", yylval.str_val);}
	
bloque_programa : bloque_programa sentencia | sentencia

sentencia: asignacion | bloque_condicional | asignacion_multiple

asignacion: ID OPERADOR_ASIGNACION expresion PUNTO_Y_COMA

expresion:  expresion OPERACION_SUMA termino | expresion OPERACION_RESTA termino | termino

termino: termino OPERACION_MULTIPLICACION factor | termino OPERACION_DIVISION factor | factor

factor: ID
		|ENTERO
		| REAL
		| CADENA
		|PARENTESIS_ABIERTO expresion PARENTESIS_CERRADO
		|filtro
		
bloque_condicional: bloque_if {printf("bloque_condicional\n");}

bloque_if: OPERADOR_IF condicion bloque_programa ENDIF | OPERADOR_IF condicion  bloque_programa ELSE bloque_programa ENDIF 

condicion: PARENTESIS_ABIERTO comparacion OPERADOR_AND comparacion PARENTESIS_CERRADO 

			| PARENTESIS_ABIERTO comparacion OPERADOR_OR comparacion PARENTESIS_CERRADO
			
			| PARENTESIS_ABIERTO OPERADOR_NOT condicion PARENTESIS_CERRADO 

			|PARENTESIS_ABIERTO comparacion PARENTESIS_CERRADO 		// condicion simple
			
comparacion : expresion OPERADOR_MAYOR_A expresion
				
			| expresion OPERADOR_MENOR_A expresion
			
			| expresion OPERADOR_MAYOR_O_IGUAL_A expresion
			
			| expresion OPERADOR_MENOR_O_IGUAL_A expresion
			
			|expresion OPERADOR_IGUAL_A expresion
			
			|expresion OPERADOR_DISTINTO_A expresion
			
filtro: FILTER PARENTESIS_ABIERTO condicion_filter COMA  CORCHETE_ABIERTO lista_ids CORCHETE_CERRADO PARENTESIS_CERRADO {printf("hay un filter\n");}

condicion_filter: comparacion_filter OPERADOR_AND comparacion_filter 
				
				|comparacion_filter OPERADOR_OR comparacion_filter
				
				| comparacion_filter
				
comparacion_filter: GUION_BAJO OPERADOR_MAYOR_A expresion
					
				| GUION_BAJO OPERADOR_MENOR_A expresion

				| GUION_BAJO OPERADOR_MAYOR_O_IGUAL_A expresion
				
				| GUION_BAJO OPERADOR_MENOR_O_IGUAL_A expresion
				
				| GUION_BAJO OPERADOR_IGUAL_A expresion
				
				| GUION_BAJO OPERADOR_DISTINTO_A expresion
				
asignacion_multiple: CORCHETE_ABIERTO lista_ids CORCHETE_CERRADO OPERADOR_ASIGNACION CORCHETE_ABIERTO lista_expresiones CORCHETE_CERRADO {printf("hay una asignacion multiple\n");}
 
lista_expresiones : lista_expresiones COMA ENTERO 
				
				| lista_expresiones COMA REAL
				
				| ENTERO
				
				| REAL



%%

int main(int argc,char *argv[])
{
  if ((yyin = fopen(argv[1], "rt")) == NULL)
  {
     printf("\nNo se puede abrir el archivo: %s\n", argv[1]);
  }
  else
  {
      
      yyparse();
      
	  for(i=0;i<min;i++){
	  printf("tipo: %s, valor: %s\n",vectorAlmacenamiento[i].tipo,vectorAlmacenamiento[i].valor);
	  }
  }
  fclose(yyin);
  return 0;
}


void mostrarError(char *mensaje) {
  printf("%s\n", mensaje);
  yyerror();
}

int yyerror(void)
{
    printf("ERROR EN COMPILACION.\n");
    system ("Pause");
    exit (1);
 }

void guardarEnVectorAlmacenamiento(int opc, char * cad){
  if(opc==1){
    strcpy(vectorAlmacenamiento[cant_tipo_variable].tipo,cad);
    cant_tipo_variable++;
  }else
  
  {      strcpy(vectorAlmacenamiento[cant_variables].valor,cad);
        cant_variables++;
  }

}

void guardarTipo(char * tipoVariable) {
  strcpy(tipoVariableActual, tipoVariable);
}

void ignorarNodeclaradas()			// en min me quedan el numero maximo de variables declaradas
{		

		if(cant_tipo_variable>cant_variables)
		{max=cant_tipo_variable;
		min=cant_variables;}
		else
		{max=cant_variables;
		min=cant_tipo_variable;}
		
	for(i=0;i<max;i++)
	{
		if(strcmp(vectorAlmacenamiento[i].tipo,"")==0 || strcmp(vectorAlmacenamiento[i].valor,"")== 0)
		{
		strcpy(vectorAlmacenamiento[i].tipo, "");
		strcpy(vectorAlmacenamiento[i].valor, "");
		 
		}
	}

}