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

/* --------------- CONSTANTES --------------- */
#define TAM_NOMBRE 32	/* Limite tamaño nombre (sumar 1 para _ ) */
#define CteString "CTE_STRING"

/* --------------- PROTOTIPO DE FUNCIONES PRIMERA ENTREGA --------------- */
void guardarTabla(void);
void agregarEntero(int);
void agregarReal(char*);
void agregarCadena(char*);
int buscarCte(char* , char*);

int cantidadTokens = 0;

int i=0; 
int j=0;
int cant_elementos=0;
int min=0;
int pos_td=0;
int pos_cv=0;
int cant_variables=0;
int cant_tipo_dato=0; 
int diferencia=0;
int cant_ctes=0;

// TABLA SIMBOLOS
typedef struct
{
    char nombre[100];
    char tipo  [11];
    char valor [100];
    int longitud;
} struct_tabla_de_simbolos;

struct_tabla_de_simbolos tablaDeSimbolos[200];

char tipoVariableActual[20];

void copiarCharEn(char **, char*);
char* operadorAux;
char* idAux;

int yylex();
int yyerror();

void mostrarError(char *mensaje);
void guardarTipo(char * tipoVariable);
void guardarEnVectorTablaSimbolos(int opc, char * cad);
void acomodarPunterosTS();
void quitarDuplicados();

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
		{ quitarDuplicados(); 
		printf("bloque_definiciones OK\n\n");
		cant_ctes=cantidadTokens;	
		};

lista_definiciones: lista_definiciones definicion {	printf("lista_definiciones -> lista_definiciones definicion OK\n\n");} 
					| definicion {	printf("lista_definiciones -> definicion OK\n\n");}

definicion: CORCHETE_ABIERTO lista_tipo_dato CORCHETE_CERRADO DOS_PUNTOS CORCHETE_ABIERTO lista_ids CORCHETE_CERRADO 
		{ acomodarPunterosTS(); printf("definicion OK\n\n");};

lista_tipo_dato: lista_tipo_dato COMA tipo_dato	{ printf("lista_tipo_dato -> lista_tipo_dato , tipo_dato OK\n\n");} 
					| tipo_dato {printf("lista_tipo_dato -> tipo_dato OK \n\n");}

tipo_dato: 
  TIPO_ENTERO { 
      guardarTipo("ENTERO");
      guardarEnVectorTablaSimbolos(1,tipoVariableActual);
      printf("TIPO_ENTERO en tipo_variable OK\n");
    }
  | TIPO_REAL {
      guardarTipo("REAL");
      guardarEnVectorTablaSimbolos(1,tipoVariableActual);
      printf("TIPO_REAL en tipo_variable OK\n");
    }
  | TIPO_CADENA{
      guardarTipo("CADENA");
      guardarEnVectorTablaSimbolos(1,tipoVariableActual);
      printf("TIPO_CADENA en tipo_variable OK\n");
    }

lista_ids: 
  lista_ids COMA ID {
      printf("%s\n", yylval.str_val);
      guardarEnVectorTablaSimbolos(2,yylval.str_val);
      printf("lista_ids -> lista_ids , ID OK\n\n");
    }
  | ID {
      printf("%s\n", yylval.str_val);
      guardarEnVectorTablaSimbolos(2,yylval.str_val);
      printf("lista_ids -> ID OK\n\n");
    }

	
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
		| CADENA	{agregarCadena(yylval.str_val);}
		| PARENTESIS_ABIERTO expresion PARENTESIS_CERRADO
		| filtro
		
bloque_condicional: bloque_if {printf("bloque_condicional\n");}

bloque_if: OPERADOR_IF condicion bloque_programa OPERADOR_ENDIF 
		| OPERADOR_IF condicion  bloque_programa OPERADOR_ELSE bloque_programa OPERADOR_ENDIF 

condicion : PARENTESIS_ABIERTO comparacion OPERADOR_AND comparacion PARENTESIS_CERRADO 
			| PARENTESIS_ABIERTO comparacion OPERADOR_OR comparacion PARENTESIS_CERRADO
			| PARENTESIS_ABIERTO OPERADOR_NOT condicion PARENTESIS_CERRADO 
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
				| OPERADOR_NOT  comparacion_filter
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

termino_numerico: termino_numerico OPERACION_MULTIPLICACION factor_numerico {printf("term -> term * factor_numerico OK \n\n");} 
		| termino_numerico OPERACION_DIVISION factor_numerico 	{printf("term -> term / factor_numerico OK \n\n");}
		| factor_numerico			{printf("term -> factor_numerico OK \n\n");}

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
		printf("----- TABLA DE SIMBOLOS -----\n");
		for(i=0;i<cant_ctes;i++){
			
			printf("tipo: %s, nombre: %s\n, valor: %s, longitud: %d",tablaDeSimbolos[i].tipo,tablaDeSimbolos[i].nombre,tablaDeSimbolos[i].valor,tablaDeSimbolos[i].longitud);
		}
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

void guardarEnVectorTablaSimbolos(int opc, char * cad){
	if(opc==1){
		strcpy(tablaDeSimbolos[pos_td].tipo,cad);
		cant_tipo_dato++;
		pos_td++;
	}else{
		strcpy(tablaDeSimbolos[pos_cv].nombre,cad);
        pos_cv++;
		cant_variables++;
	}
}

void guardarTipo(char * tipoVariable) {
	strcpy(tipoVariableActual, tipoVariable);
}

void acomodarPunterosTS(){
	int indice=0;
	if(cant_tipo_dato!=cant_variables){
		if(pos_td<pos_cv){	
			min=pos_td;
			cant_elementos=min;
			pos_td=pos_cv=min;
			diferencia=(cant_variables-cant_tipo_dato);
			indice=min;
			while(diferencia>0){
				strcpy(tablaDeSimbolos[indice].tipo, "");
				strcpy(tablaDeSimbolos[indice].nombre, "");
				diferencia--;
				indice++;
			}
		}else{
			min=pos_cv;
			cant_elementos=min;
			pos_td=pos_cv=min;
			diferencia=(cant_tipo_dato-cant_variables);
			indice=min;
			while(diferencia>0){
				strcpy(tablaDeSimbolos[indice].tipo, "");
				strcpy(tablaDeSimbolos[indice].nombre, "");
				diferencia--;
				indice++;
			}
		}
	}else{
		cant_elementos=pos_cv;
		cant_tipo_dato=cant_variables=0;
	}
}

void quitarDuplicados(){
	for(i=0;i<cant_elementos;i++){
		if(strcmp(tablaDeSimbolos[i].nombre,"@")!=0){
			cantidadTokens++;
			for(j=i+1;j<cant_elementos;j++){
				if(strcmp(tablaDeSimbolos[i].tipo,tablaDeSimbolos[j].tipo)==0 
						&& strcmp(tablaDeSimbolos[i].nombre,tablaDeSimbolos[j].nombre)==0){
					strcpy(tablaDeSimbolos[j].tipo, "@");
					strcpy(tablaDeSimbolos[j].nombre, "@");
				}
			}
		}else{
			j=i+1;
			while(j<cant_elementos && strcmp(tablaDeSimbolos[j].tipo,"@")==0){
				j++;
				if(j<cant_elementos){
					strcpy(tablaDeSimbolos[i].nombre,tablaDeSimbolos[j].nombre);
					strcpy(tablaDeSimbolos[i].tipo,tablaDeSimbolos[j].tipo);
				}else{
					i=cant_elementos;
				}
			}
		}
	}
}


/* Guarda la tabla generada en un txt */
void guardarTabla(){

	// Verifico si se cargo algo en la tabla
	if(cantidadTokens == -1)
		yyerror();

	FILE* arch = fopen("ts.txt", "w+");
	if(!arch){
		printf("No pude crear el archivo ts.txt\n");
		return;
	}

	fprintf(arch,"%-30s%-20s%-30s%-5s\n","NOMBRE","TIPO","VALOR", "LONGITUD");
	fprintf(arch, "======================================================================================================\n");

	// Recorro la tabla
	int i = 0;
	while (i < cant_ctes) {

		fprintf(arch, "%-30s%-20s%-30s%-5d\n", &(tablaDeSimbolos[i].nombre), &(tablaDeSimbolos[i].tipo) , &(tablaDeSimbolos[i].valor), tablaDeSimbolos[i].longitud);
		i++;
	}

	fclose(arch);
}



/* Agregar cadena a la tabla de simbolos */
void agregarCadena(char* nombre) {

	// Formateo la cadena
	int length = strlen(nombre);
	printf("LONGITUD: %d\n",length);
	printf("CADENA QUE MANDE: %s\n", nombre);
	char nombre_nuevo[length];
	strcpy(nombre_nuevo, "_");
	strcat(nombre_nuevo, nombre);
	printf("nombre_nuevo + nombre: %s\n", nombre_nuevo);
	strcpy(nombre_nuevo + strlen(nombre_nuevo), "\0");
	printf("nombre_nuevo: %s\n", nombre_nuevo);

	// Verificamos si ya esta cargada
	if (buscarCte(nombre_nuevo, CteString) == 0) {

		// Agrego nombre a la tabla
		strcpy(tablaDeSimbolos[cant_ctes].nombre, nombre_nuevo);

		// Agrego el tipo (Se utiliza para imprimir tabla)
		strcpy(tablaDeSimbolos[cant_ctes].tipo, CteString);	

		// Agrego valor
		strcpy(tablaDeSimbolos[cant_ctes].valor, nombre_nuevo+1);		// Omito el _

		// Agrego la longitud
		tablaDeSimbolos[cant_ctes].longitud = length;
		
		cant_ctes++;
		
		printf("AGREGO A LA TABLA: %s\n", nombre_nuevo);
	}
}

/* Agregar entero a la tabla de simbolos */
void agregarEntero(int valor) {

	// Agrego _ al nombre
	char nombre_nuevo[TAM_NOMBRE];
	sprintf(nombre_nuevo, "_%d", valor);

	// Verificamos si ya esta cargada
	//if (buscarCte(nombre_nuevo, CteInt) == -1) {

		// Avanzo una posicion en la tabla
		cantidadTokens++;

		// Agrego nombre a la tabla
		strcpy(tablaDeSimbolos[cantidadTokens].nombre, nombre_nuevo);

		// Agrego el tipo (Se utiliza para imprimir tabla)
		//tablaDeSimbolos[cantidadTokens].tipo = '';	
		strcpy(tablaDeSimbolos[cantidadTokens].tipo,"ENTERO");	

		// Agrego el valor
		//tablaDeSimbolos[cantidadTokens].valor = valor;
		
		sprintf(tablaDeSimbolos[cantidadTokens].valor, "%d", valor);
		
	//}
}

/* Agregar real a la tabla de simbolos */
void agregarReal(char* valor) {

	// Agrego _ al nombre
	char nombre_nuevo[TAM_NOMBRE];
	sprintf(nombre_nuevo, "_%f", atof(valor));

	// Verificamos si ya esta cargada
	//if (buscarCte(nombre_nuevo, CteFloat) == -1) {

		// Avanzo una posicion en la tabla
		cantidadTokens++;

		// Agrego nombre a la tabla
		strcpy(tablaDeSimbolos[cantidadTokens].nombre, nombre_nuevo);

		// Agrego el tipo (Se utiliza para imprimir tabla)
		//tablaDeSimbolos[cantidadTokens].tipo = '';	
		strcpy(tablaDeSimbolos[cantidadTokens].tipo,"REAL");

		// Agrego el valor
		//tablaDeSimbolos[cantidadTokens].valor = atof(valor);
		sprintf(tablaDeSimbolos[cantidadTokens].valor, "%f", atof(valor));
		
	//}
}

int buscarCte(char* cad1, char* cad2){			//return 1 = ya esta, return 0 = no esta
int i=0;
for(i=cantidadTokens;i<cant_ctes;i++)
{
if(strcmp(tablaDeSimbolos[i].nombre, cad1)==0 && strcmp(tablaDeSimbolos[i].tipo,cad2)==0)
	{printf("CTE_STRING DUPLICADA\n\n");
	return 1;
	}
}
return 0;
}
