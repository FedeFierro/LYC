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
char mensajeDeError[200];

/* --------------- CONSTANTES --------------- */
#define TAM_NOMBRE 32	/* Limite tamaño nombre (sumar 1 para _ ) */
#define CteString "CTE_STRING"
#define CteInt "CTE_INT"
#define CteReal "CTE_REAL"

// TABLA SIMBOLOS
typedef struct
{
    char nombre[100];
    char tipo  [11];
    char valor [100];
    int longitud;
} struct_tabla_de_simbolos;

struct_tabla_de_simbolos tablaDeSimbolos[200];



/* --------------- PROTOTIPO DE FUNCIONES PRIMERA ENTREGA --------------- */
void guardarTabla(void);
void agregarConstante(char*,char*);
int buscarCte(char* , char*);
void validarVariableDeclarada(char* nombre);
void mostrarError(char *mensaje);
void guardarTipo(char * tipoVariable);
void guardarEnVectorTablaSimbolos(int opc, char * cad);
void acomodarPunterosTS();
void quitarDuplicados();
void copiarCharEn(char **, char*);

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
int finBloqueDeclaraciones=0;


char tipoVariableActual[20];


char* operadorAux;
char* idAux;

int yylex();
int yyerror();

/*Funciones para tercetos*/
#define DEBUG		0
#define PILA_EXPRESION	1
#define PILA_FACTOR	2
#define PILA_OPERADOR 3
#define PILA_IF 4
#define PILA_WHILE 5

struct node
{
    char data[100];
    struct node *link;
};


typedef struct terceto {
							char ope[35];
							char te1[30];
							char te2[30];
							int nrot;
						}	terceto;
				
terceto Eind;
terceto Tind;
terceto Find;
terceto Aind;
terceto AVGind;



// Variable para guardar el dato (float o string) asignado a un id.
char id_aux[30];

terceto crear_terceto(char*, char*, char*);
terceto * buscar_terceto(terceto);
void escribe_arch_tercetos();
void imprimir_terceto_arch(terceto, FILE *);
void imp_txt(char *);


char aux4[40];
char aux5[40];
terceto * vector_tercetos; // vectro de tercetos
int indice_terceto = 0;	   // Cantidad de elementos e indice de tercetos


//estructura del terceto operacion, tiene los valores de los numeros de tercetos que se estan usando
typedef struct terceto_operacion	{
										int exp;
										int ter;
										int	fac;
									} terceto_operacion;

//nodo de los tercetos de operaciones
struct nodo_operaciones	{
							terceto_operacion ope;
							struct nodo_operaciones *link;
						} *pila_ope = NULL;

struct nodo_operacion	{
							char ope[2];
							struct nodo_operacion *sig;
						}*pila_exp, *pila_fac;
								
void setearTercetoOperacionActual(int, int, int);
terceto_operacion obtenerTercetoOperacionActual();								
								
void addNivelPar();
terceto_operacion delNivelPar();

void apilar_oper(int, char*);
void desapilar_oper(int, char*);
void negar_terceto(int p_ind);

void apilar(int, char *);
int desapilar(int);

struct node *pila_operador = NULL, *pila_while = NULL, *pila_if = NULL;
/*-----------------------------------------------------------------------*/

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
PRINT
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
		finBloqueDeclaraciones=1;
		quitarDuplicados(); 
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
      printf("TIPO_ENTERO en tipo_variable OK\n\n");
    }
  | TIPO_REAL {
      guardarTipo("REAL");
      guardarEnVectorTablaSimbolos(1,tipoVariableActual);
      printf("TIPO_REAL en tipo_variable OK\n\n");
    }
  | TIPO_CADENA{
      guardarTipo("CADENA");
      guardarEnVectorTablaSimbolos(1,tipoVariableActual);
      printf("TIPO_CADENA en tipo_variable OK\n\n");
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
					
entrada_datos: READ ID	{ printf("READ ID OK \n\n");}

salida_datos: PRINT CADENA {printf("PRINT CADENA OK \n\n");}
			| PRINT ID  { printf("PRINT ID OK\n\n");}

bloque_iteracion: REPEAT bloque_programa UNTIL condicion {printf("bloque REPEAT-UNTIL OK\n\n");}

asignacion: ID OPERADOR_ASIGNACION expresion PUNTO_Y_COMA	{printf("asignacion OK\n\n");}

expresion:  expresion OPERACION_SUMA termino	{printf("expresion -> exp + term OK \n\n");} 
			| expresion OPERACION_RESTA termino 	{printf("expresion -> exp - term OK \n\n");}
			| termino							{printf("expresion -> term OK \n\n");}

termino: termino OPERACION_MULTIPLICACION factor {printf("term -> term * factor OK \n\n");} 
		| termino OPERACION_DIVISION factor 	{printf("term -> term / factor OK \n\n");}
		| factor			{printf("term -> factor OK \n\n");}

factor: ID 
		| ENTERO 	{printf("factor -> Cte_entera OK\n\n");agregarConstante(yylval.str_val,CteInt);}
		| REAL		{printf("factor -> Cte_Real OK\n\n");agregarConstante(yylval.str_val,CteReal);}	
		| CADENA	{printf("factor -> Cte_string OK\n\n");agregarConstante(yylval.str_val,CteString);}
		| PARENTESIS_ABIERTO expresion PARENTESIS_CERRADO	{printf("factor -> ( expresion ) OK\n\n");}
		| filtro {printf("factor -> filtro OK\n\n");}
		
bloque_condicional: bloque_if {printf("bloque_condicional OK\n\n\n");}

bloque_if: OPERADOR_IF condicion bloque_programa OPERADOR_ENDIF	{printf("bloque_if -> IF condicion programa ENDIF\n\n");} 
		| OPERADOR_IF condicion  bloque_programa OPERADOR_ELSE bloque_programa OPERADOR_ENDIF {printf("bloque_if -> IF condicion programa ELSE programa ENDIF\n\n");}

condicion : PARENTESIS_ABIERTO comparacion OPERADOR_AND comparacion PARENTESIS_CERRADO 
			| PARENTESIS_ABIERTO comparacion OPERADOR_OR comparacion PARENTESIS_CERRADO
			| PARENTESIS_ABIERTO OPERADOR_NOT PARENTESIS_ABIERTO condicion PARENTESIS_CERRADO PARENTESIS_CERRADO 
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
				| OPERADOR_NOT PARENTESIS_ABIERTO comparacion_filter PARENTESIS_CERRADO
				| comparacion_filter
				
comparacion_filter : GUION_BAJO OPERADOR_MAYOR_A expresion_numerica	
					| GUION_BAJO OPERADOR_MENOR_A expresion_numerica
					| GUION_BAJO OPERADOR_MAYOR_O_IGUAL_A expresion_numerica
					| GUION_BAJO OPERADOR_MENOR_O_IGUAL_A expresion_numerica
					| GUION_BAJO OPERADOR_IGUAL_A expresion_numerica
					| GUION_BAJO OPERADOR_DISTINTO_A expresion_numerica

				
asignacion_multiple: CORCHETE_ABIERTO lista_ids CORCHETE_CERRADO OPERADOR_ASIGNACION CORCHETE_ABIERTO lista_expresiones CORCHETE_CERRADO 
		{printf("ASIGNACION MULTIPLE OK\n\n");}
 
lista_expresiones : lista_expresiones COMA expresion_numerica
				| expresion_numerica


expresion_numerica: expresion_numerica OPERACION_SUMA termino_numerico	{printf("expresion_numerica -> exp + term OK \n\n");} 
			| expresion_numerica OPERACION_RESTA termino_numerico 	{printf("expresion_numerica -> exp - term OK \n\n");}
			| termino_numerico							{printf("expresion_numerica -> term OK \n\n");}

termino_numerico: termino_numerico OPERACION_MULTIPLICACION factor_numerico {printf("term -> term * factor_numerico OK \n\n");} 
		| termino_numerico OPERACION_DIVISION factor_numerico 	{printf("term -> term / factor_numerico OK \n\n");}
		| factor_numerico			{printf("term -> factor_numerico OK \n\n");}

factor_numerico: ID 
		| ENTERO {	agregarConstante(yylval.str_val, CteInt);}
		| REAL {	agregarConstante(yylval.str_val, CteReal);}	
		| PARENTESIS_ABIERTO expresion_numerica PARENTESIS_CERRADO
		| filtro


%%

int main(int argc,char *argv[]){
	if ((yyin = fopen(argv[1], "rt")) == NULL){
		printf("\nNo se puede abrir el archivo: %s\n", argv[1]);
	}else {
		yyparse();
		/*printf("----- TABLA DE SIMBOLOS -----\n");
		for(i=0;i<cant_ctes;i++){
			
			printf("tipo: %s, nombre: %s\n, valor: %s, longitud: %d",tablaDeSimbolos[i].tipo,tablaDeSimbolos[i].nombre,tablaDeSimbolos[i].valor,tablaDeSimbolos[i].longitud);
		}*/
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
	if(finBloqueDeclaraciones==0){
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
				if(strcmp(tablaDeSimbolos[i].tipo,tablaDeSimbolos[j].tipo)==0 && strcmp(tablaDeSimbolos[i].nombre,tablaDeSimbolos[j].nombre)==0){		// si los dos son iguales
					strcpy(tablaDeSimbolos[j].tipo, "@");
					strcpy(tablaDeSimbolos[j].nombre, "@");				// doy de baja a todos los proximos que son iguales
				}
			}
		}else{
			j=i+1;
			while(j<cant_elementos && strcmp(tablaDeSimbolos[j].tipo,"@")==0)
				j++;
				if(j<cant_elementos){
					strcpy(tablaDeSimbolos[i].nombre,tablaDeSimbolos[j].nombre);
					strcpy(tablaDeSimbolos[i].tipo,tablaDeSimbolos[j].tipo);
					i--;
				}else{
					i=cant_elementos;
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
    //lo mismo que guarda en archivo lo imprimo en pantalla
    printf("%-30s%-20s%-30s%-5s\n","NOMBRE","TIPO","VALOR", "LONGITUD");
    printf("======================================================================================================\n");
	// Recorro la tabla
	int i = 0;
	while (i < cant_ctes) {

		fprintf(arch, "%-30s%-20s%-30s%-5d\n", &(tablaDeSimbolos[i].nombre), &(tablaDeSimbolos[i].tipo) , &(tablaDeSimbolos[i].valor), tablaDeSimbolos[i].longitud);
        printf( "%-30s%-20s%-30s%-5d\n", &(tablaDeSimbolos[i].nombre), &(tablaDeSimbolos[i].tipo) , &(tablaDeSimbolos[i].valor), tablaDeSimbolos[i].longitud);
		i++;
	}

	fclose(arch);
}


/* Agregar una constante a la tabla de simbolos */

void agregarConstante(char* nombre,char* tipo) {
	printf("Agregar cte %s: %s .\n\n",nombre, tipo);

	// Formateo la cadena
	int length = strlen(nombre);

	char nombre_nuevo[length];
	
	strcpy(nombre_nuevo, "_");
	strcat(nombre_nuevo, nombre);
	
	strcpy(nombre_nuevo + strlen(nombre_nuevo), "\0");
	
	// Verificamos si ya esta cargada
	if (buscarCte(nombre_nuevo, tipo) == 0) {

		// Agrego nombre a la tabla
		strcpy(tablaDeSimbolos[cant_ctes].nombre, nombre_nuevo);

		// Agrego el tipo (Se utiliza para imprimir tabla)
		strcpy(tablaDeSimbolos[cant_ctes].tipo, tipo);	

		// Agrego valor
		strcpy(tablaDeSimbolos[cant_ctes].valor, nombre_nuevo+1);		// Omito el _

		// Agrego la longitud
		if(strcmp(tipo, CteString)==0){
			tablaDeSimbolos[cant_ctes].longitud = length;
		}
		cant_ctes++;
		printf("AGREGO A LA TABLA: %s\n", nombre_nuevo);
	}
}

int buscarCte(char* nombre, char* tipo){			//return 1 = ya esta, return 0 = no esta , cad1 es nombre a buscar cad2 es el tipo 
	int i = cantidadTokens;
	for( i ; i < cant_ctes ; i++){
		if(strcmp(tablaDeSimbolos[i].nombre, nombre)==0 
				&& strcmp(tablaDeSimbolos[i].tipo,tipo)==0){
			printf("%s DUPLICADA\n\n", tipo);
			return 1;
		}
	}
	return 0;
}

void validarVariableDeclarada(char* nombre){
	int i;
	for(i=0 ; i< cantidadTokens; i++){
		if(strcmp(tablaDeSimbolos[i].nombre,nombre)==0)
			return;
		
	}
	sprintf(mensajeDeError, "La Variable: %s - No esta declarada.\n", nombre);
	mostrarError(mensajeDeError);
	
}


/*Funciones tercetps*/
/*Pila*/
// borra un elemento de la pila
int desapilar(int p_des)
{
	int res;
    struct node *temp;
    
	switch(p_des){
		case PILA_OPERADOR:
	        temp = pila_operador;
		    pila_operador = pila_operador->link;
	    	break;
		case PILA_WHILE:
	        temp = pila_while;
		    pila_while = pila_while->link;
	    	break;
		case PILA_IF:
	        temp = pila_if;
		    pila_if = pila_if->link;
    	break;
		
    }
// inserta un elemento en la pila
void apilar(int p_des, char * p_dato, struct node *pila_operador ,struct node *pila_while, struct node *pila_if)
{
    struct node *temp;
    
	temp = (struct node *) malloc (sizeof(struct node));

	strcpy(temp->data , p_dato);
    
	switch(p_des){
    	case PILA_OPERADOR:
	    	temp->link = pila_operador;
	    	pila_operador = temp;
    	break;
	case PILA_WHILE:
	    	temp->link = pila_while;
	    	pila_while = temp;
		break;
	case PILA_IF:
	    	temp->link = pila_if;
	    	pila_if = temp;
		break;
		
    }
}    
	res = atoi(temp->data);
    free(temp);
	return res;
}

void desapilar_oper(int p_dest, char* p_res)
{
    struct nodo_operacion *temp;
    
	switch(p_dest)
	{
    	case PILA_EXPRESION:
	    	if (pila_exp != NULL)
		    {
		        temp = pila_exp;
		        pila_exp = pila_exp->sig;
		    }	
    	break;
    	case PILA_FACTOR:
	    	if (pila_fac != NULL)
		    {
		        temp = pila_fac;
		        pila_fac = pila_fac->sig;
		    }	
    	break;
    }
	
	strcpy(p_res, temp->ope);
    
	free(temp);
}
void apilar_oper(int p_dest, char* p_ope)
{
	struct nodo_operacion *temp;
    
	temp = (struct nodo_operacion *) malloc (sizeof(struct nodo_operacion));

    strcpy(temp->ope, p_ope);
	
    switch(p_dest)
	{
    	case PILA_EXPRESION:
	    	temp->sig = pila_fac;
	    	pila_exp = temp;	
    	break;
    	case PILA_FACTOR:
    		temp->sig = pila_fac;
	    	pila_fac = temp;	
    	break;
    }
}
// Genera una cadena string con un terceto


void terceto_a_string(terceto p_ter, char * p_ster) 
{	
	if(strcmp(p_ter.ope, "BI") == 0)  // salto incondicional
		sprintf(p_ster, "[%d] (%s, [%s], -)", p_ter.nrot, p_ter.ope, p_ter.te2);
	else 
		if(strcmp(p_ter.te1, "-1") == 0 && strcmp(p_ter.te2, "-1") == 0 ) // terceto de asignacion de memoria
			sprintf(p_ster, "[%d] (%s, _, _)", p_ter.nrot, p_ter.ope);
		else 
			if(strcmp(p_ter.te2, "-1") == 0) // terceto en el caso cuando se escriben los cmp 
				sprintf(p_ster, "[%d] (%s, [%s], _)", p_ter.nrot, p_ter.ope, p_ter.te1);
			else // terceto completo
				sprintf(p_ster, "[%d] (%s, [%s], [%s])", p_ter.nrot, p_ter.ope, p_ter.te1, p_ter.te2);

	//printf("funcion que terceto_a_string: nrot %d terceto %s\n", p_ter.nrot, p_ster);
				
}

// Niega la la condicion de un terceto
void negar_terceto(int p_ind)
{
	if(strcmp(vector_tercetos[p_ind].ope, "BLT") == 0)
		strcpy(vector_tercetos[p_ind].ope, "BGE");
	else 
		if(strcmp(vector_tercetos[p_ind].ope, "BGE") == 0)
			strcpy(vector_tercetos[p_ind].ope, "BLT");
		else 
			if(strcmp(vector_tercetos[p_ind].ope, "BGT") == 0)
				strcpy(vector_tercetos[p_ind].ope, "BLE");
			else 
				if(strcmp(vector_tercetos[p_ind].ope, "BLE") == 0)
					strcpy(vector_tercetos[p_ind].ope, "BGT");
				else 
					if(strcmp(vector_tercetos[p_ind].ope, "BEQ") == 0)
						strcpy(vector_tercetos[p_ind].ope, "BNE");
					else 
						if(strcmp(vector_tercetos[p_ind].ope, "BNE") == 0)
							strcpy(vector_tercetos[p_ind].ope, "BEQ");
}

// decrementa el nivel de parentesis para operar
terceto_operacion delNivelPar()
{
	terceto_operacion res;
	
    struct nodo_operaciones *temp;
	
	if (pila_ope != NULL)
	{
		temp = pila_ope;
		pila_ope = pila_ope->link;
	}
	
	res = temp->ope;
	
	setearTercetoOperacionActual(-1, -1, Eind.nrot);
    
	free(temp);
	
	return res;
}
// permite modificar los valores de terceto de operacion
void setearTercetoOperacionActual(int p_exp, int p_ter, int p_fac)
{
	if(p_exp >= 0)
		pila_ope->ope.exp = p_exp;
	
	if(p_ter >= 0)
		pila_ope->ope.ter = p_ter;
	
	if(p_fac >= 0)
		pila_ope->ope.fac = p_fac;
}

// devuelve el terceto de operacion actual 
terceto_operacion obtenerTercetoOperacionActual()
{
	return pila_ope->ope;
}

// crea un nuevo nivel de parentesis para operar
void addNivelPar()
{
	struct nodo_operaciones *temp;
	
	temp = (struct nodo_operaciones *) malloc (sizeof(struct nodo_operaciones));
	
	temp->ope.exp = -1;
	temp->ope.ter = -1;
	temp->ope.fac = -1;
	temp->link = pila_ope;
	pila_ope = temp;
}
//imprime un terceto en un urchivo
void imprimir_terceto_arch(terceto p_ter, FILE * p_arch)
{	
	if(strcmp(p_ter.ope, "BI") == 0) //salto incondicional
		fprintf(p_arch, "[%d] (%s, [%d], -)\n", p_ter.nrot, p_ter.ope, p_ter.te2);
	else 
		if(strcmp(p_ter.te1, "-1") == 0 && strcmp(p_ter.te2 , "-1") ==0 ) //terceto de asignacion de memoria
			fprintf(p_arch, "[%d] (%s, _, _)\n", p_ter.nrot, p_ter.ope);
		else 
			if(strcmp(p_ter.te2 , "-1") == 0) //terceto en el caso cuando se escriben los cmp 
				fprintf(p_arch, "[%d] (%s, %s, _)\n", p_ter.nrot, p_ter.ope, p_ter.te1);
			else //terceto completo
				fprintf(p_arch, "[%d] (%s, %s, %s)\n", p_ter.nrot, p_ter.ope, p_ter.te1, p_ter.te2);	
}
// escribe los tercetos en un archivo
void escribe_arch_tercetos( )
{
	int i;
	FILE * arch;

	arch = fopen("intermedia.txt", "w+");
	
	for(i = 0; i < indice_terceto; i++)
		imprimir_terceto_arch(vector_tercetos[i], arch);		
	
	terceto taux = crear_terceto("fin", "-1", "-1");
	
	imprimir_terceto_arch(taux, arch);
	
	fclose(arch);
}

//Busca un terceto en el vector de tercetos
terceto * buscar_terceto(terceto p_ter)
{
	int i;
	
	for (i = 0; i < indice_terceto; ++i) 
		if(strcmp(vector_tercetos[i].ope, p_ter.ope) == 0 && strcmp(vector_tercetos[i].te1, "-1") == 0 && strcmp(vector_tercetos[i].te2, "-1") == 0)
			return &(vector_tercetos[i]); 

	return NULL;
}
//Crea el terceto con los indices de los tercetos. Si no existen tiene -1
terceto crear_terceto(char* p_ope, char* p_te1, char* p_te2)
{
	terceto res;
	terceto *tmp;
	terceto *teraux;
	
	strcpy(res.ope, p_ope);
	strcpy(res.te1, p_te1);
	strcpy(res.te2, p_te2);
	
	teraux = buscar_terceto(res);
	
	if(indice_terceto > 0 && teraux != NULL)
		res = *teraux;
	else{
		res.nrot = indice_terceto++;
		vector_tercetos = (terceto *) realloc (vector_tercetos, sizeof(terceto) * indice_terceto);
		vector_tercetos[indice_terceto-1] = res;
		
		//printf("terceto creado [%d] (%s, %s, %s)\n", res.nrot, res.ope, res.te1, res.te2);
	}
	
	return res;
}