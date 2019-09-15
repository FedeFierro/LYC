%{
#include <stdio.h>
#include <stdlib.h>
#include <conio.h>
#include <string.h>
#include "y.tab.h"

#define LIMITE_REAL 2147483647
#define LIMITE_ENTERO 32768
#define LIMITE_CADENA 30
#define LIMITE_ID 30
#define CteString "CTE_STRING"
#define CteInt "CTE_INT"
#define CteReal "CTE_REAL"

int validarLongitudId();
int validarLongitudReal();
int validarLongitudEntero();
int validarLongitudCadena();
void mostrarError(char*);
void finDeclaracion();
void quitarComillas();
void guardarTabla();
void agregarTipo(char* tipo);
void finalizarDefiniciones();
int buscarVariable(char* nombre);
void agregarVariable(char* nombre);
int buscarCte(char* nombre, char* tipo);
void agregarConstante(char* valor,char* tipo);


int indexTabla=0;
int cantTipos=0;
int cantVariables=0;
int cantCtes=0;
int finDefiniciones =0;

// TABLA SIMBOLOS
typedef struct
{
    char nombre[100];
    char tipo  [11];
    char valor [100];
    int longitud;
} struct_tabla_de_simbolos;

struct_tabla_de_simbolos tablaDeSimbolos[200];

FILE  *yyin;
char auxS[100];
char mensajeDeError[200];

%}
%option noyywrap  
%option yylineno 


DIGITO					[0-9]
LETRA					[a-zA-Z]
COMENTARIOS				\-\-\/([^"\/\-"|"\-\/"]|\n)*\/\-\-
COMENTARIOS_ANIDADOS	\-\-\/([^"\/\-"|"\-\/"]|\n)*{COMENTARIOS}*([^"\/\-"|"\-\/"]|\n)*\/\-\-
ID						{LETRA}({LETRA}|{DIGITO}|_)*
REAL					({DIGITO}*"."{DIGITO}+|{DIGITO}+".")
ENTERO					{DIGITO}+
CADENA					\"[^"\n]*\"
DEFAULT 				(.)

%%

{COMENTARIOS}				{}
{COMENTARIOS_ANIDADOS}		{}

"REPEAT"   					{return REPEAT;}
"UNTIL"						{return UNTIL;}
"+"							{return OPERACION_SUMA;}
"-"							{return OPERACION_RESTA;}
"*"							{return OPERACION_MULTIPLICACION;}
"/"							{return OPERACION_DIVISION;}
"\("						{return PARENTESIS_ABIERTO;}
"\)"						{return PARENTESIS_CERRADO;}
","							{return COMA;}
":="						{return OPERADOR_ASIGNACION;}
"READ"						{return READ;}
"WRITE"						{return WRITE;}
"IF"						{return OPERADOR_IF;}
"ELSE"						{return OPERADOR_ELSE;}
"ENDIF"						{return OPERADOR_ENDIF;}
"AND"						{return OPERADOR_AND;}
"OR"						{return OPERADOR_OR;}
"NOT"						{return OPERADOR_NOT;}
">"							{return OPERADOR_MAYOR_A;}
"<"							{return OPERADOR_MENOR_A;}
">="						{return OPERADOR_MAYOR_O_IGUAL_A;}
"<="						{return OPERADOR_MENOR_O_IGUAL_A;}
"="							{return OPERADOR_IGUAL_A;}
"!="						{return OPERADOR_DISTINTO_A;}
"VAR"						{return VAR;}
"ENDVAR"					{
								finalizarDefiniciones();
								return ENDVAR;
							}
";"							{
								return PUNTO_Y_COMA;
							}
":"							{return DOS_PUNTOS;}
"FLOAT"						{
								agregarTipo(yytext);
								return TIPO_REAL;
							}
"STRING"					{
								agregarTipo(yytext);
								return TIPO_CADENA;
							}
"INT"						{	
								agregarTipo(yytext);
								return TIPO_ENTERO;
							}
"["							{return CORCHETE_ABIERTO;}
"]"							{return CORCHETE_CERRADO;}
"FILTER"					{return FILTER;}
"_"							{return GUION_BAJO;}




{ID}					{	
							sprintf(auxS,"%s", yytext);
							if(validarLongitudId() == 0) {
								sprintf(mensajeDeError, "El identificador %s excede los %d caracteres de longitud.", yytext, LIMITE_ID);
				 				mostrarError(mensajeDeError);
							}
							agregarVariable(yytext);
							yylval.str_val=auxS;
							return ID;
						}

{ENTERO}				{ 	if(validarLongitudEntero() == 0){
								sprintf(mensajeDeError, "El ENTERO %s excede el rango admitido.", yytext);
				 				mostrarError(mensajeDeError);
							}
				 			sscanf(yytext,"%d",&(yylval.int_val));
							agregarConstante(yytext, CteInt);
							return ENTERO;
						}

{REAL}					{	if(validarLongitudReal() == 0){
								sprintf(mensajeDeError, "El REAL %s excede el rango admitido.", yytext);
				 				mostrarError(mensajeDeError);
							}
				 			sscanf(yytext,"%lf",&(yylval.float_val));
							agregarConstante(yytext,CteReal);
							return REAL;
						}

{CADENA} 				{	if(validarLongitudCadena() == 0) {
								sprintf(mensajeDeError, "Cadena %s excede los %d caracteres de longitud.", yytext, LIMITE_CADENA);
				 				mostrarError(mensajeDeError);
							}
							sprintf(auxS,"%s", yytext);
							quitarComillas();
							yylval.str_val=auxS; 
							agregarConstante(auxS,CteString);
							return CADENA;
						}
"\n"      		
"\r"
"\r\n"
"\t"
" "
{DEFAULT}			{
							sprintf(mensajeDeError, "Caracter invalido: %s", yytext);
							mostrarError(mensajeDeError);
						}


%%

int validarLongitudId(){
	if(strlen(yytext) <= LIMITE_ID){
		return 1;
	}
	return 0;
}

int validarLongitudReal(){
	int real;
	sscanf(yytext,"%lf",&real);
	if(real >= -LIMITE_REAL && real <= LIMITE_REAL-1){
		return 1;
	}
	return 0;
}

int validarLongitudEntero(){
	int entero;
	sscanf(yytext,"%d",&entero);
	if(entero >= -LIMITE_ENTERO && entero <= LIMITE_ENTERO-1){
		return 1;
	}
	return 0;
}

int validarLongitudCadena(){
	if((strlen(yytext) - 2) <= LIMITE_CADENA){
		return 1;
	}
	return 0;
}

void quitarComillas() {
	int i = 0;
	while(auxS[i+1] != '\"') {
		auxS[i] = auxS[i+1];
		i++;
	}
	auxS[i] = '\0';
}

void finDeclaracion(){
	if(cantTipos > cantVariables){
		cantTipos = cantVariables;
	}
	if(cantTipos < cantVariables ){
		cantVariables = cantTipos;
	}
	indexTabla= cantTipos;
}
void finalizarDefiniciones(){
	finDefiniciones=1;
}

/* Guarda la tabla generada en un txt */
void guardarTabla(){
	// Verifico si se cargo algo en la tabla
	if(indexTabla == -1)
		yyerror();

	FILE* arch = fopen("ts.txt", "w+");
	if(!arch){
		printf("No pude crear el archivo ts.txt\n");
		return;
	}
	printf("Guardando Tablas\n");
	fprintf(arch,"%-30s%-20s%-30s%-5s\n","NOMBRE","TIPO","VALOR", "LONGITUD");
	fprintf(arch, "======================================================================================================\n");

	printf("%-30s%-20s%-30s%-5s\n","NOMBRE","TIPO","VALOR", "LONGITUD");
	printf("======================================================================================================\n");

	// Recorro la tabla
	int i = 0;
	while (i < indexTabla) {

		fprintf(arch, "%-30s%-20s%-30s%-5d\n", &(tablaDeSimbolos[i].nombre), &(tablaDeSimbolos[i].tipo) , &(tablaDeSimbolos[i].valor), tablaDeSimbolos[i].longitud);
		printf("%-30s%-20s%-30s%-5d\n", &(tablaDeSimbolos[i].nombre), &(tablaDeSimbolos[i].tipo) , &(tablaDeSimbolos[i].valor), tablaDeSimbolos[i].longitud);
		
		i++;
	}

	fclose(arch);
}
void agregarTipo(char* tipo){
	strcpy(tablaDeSimbolos[cantTipos].tipo,tipo);
	cantTipos++;
}
int buscarVariable(char* nombre){
	int i = 0;
	for(i; i < cantVariables; i++){
		if(strcmp(tablaDeSimbolos[i].nombre, nombre)==0 ){
			return 1;
		}
	}
	return 0;
}

void agregarVariable(char* nombre){
	if(  buscarVariable(nombre) == 0){ // SI no esta en la Tabla...
		if(finDefiniciones ==0){ // si es bloque de declaracion la agrego
			strcpy( tablaDeSimbolos[cantVariables].nombre,nombre);
			cantVariables++;
		}else{ // si es Bloque de programa y Ya existe la variable ERROR
			sprintf(mensajeDeError, "La Variable: %s - NO esta declarada.\n",nombre);
			mostrarError(mensajeDeError);
		}
	}
}

int buscarCte(char* nombre, char* tipo){			//return 1 = ya esta, return 0 = no esta
		int i=0;
	for( i ; i < indexTabla ; i++){
		if(strcmp(tablaDeSimbolos[i].nombre, nombre)==0 
				&& strcmp(tablaDeSimbolos[i].tipo,tipo)==0){
			return 1;
		}
	}
	return 0;
}
void agregarConstante(char* valor, char* tipo) {
	int length = strlen(valor);
	char nombre_nuevo[length];
	strcpy(nombre_nuevo, "_");
	strcat(nombre_nuevo, valor);
	strcpy(nombre_nuevo + strlen(nombre_nuevo), "\0");

	if (buscarCte(nombre_nuevo, tipo) == 0) {

		// Agrego nombre a la tabla
		strcpy(tablaDeSimbolos[indexTabla].nombre, nombre_nuevo);

		// Agrego el tipo (Se utiliza para imprimir tabla)
		strcpy(tablaDeSimbolos[indexTabla].tipo, tipo);	

		// Agrego valor
		strcpy(tablaDeSimbolos[indexTabla].valor, valor);

		// Agrego la longitud si es CADENA
		if(strcmp(tipo,CteString)==0){
			tablaDeSimbolos[indexTabla].longitud = length;
		}
		indexTabla++;
		printf("AGREGO A LA TABLA: %s\n", nombre_nuevo);
	}
}
