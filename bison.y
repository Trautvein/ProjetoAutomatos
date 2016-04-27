%{

#include <stdio.h>
#include <stdlib.h>
#include <string.h>


extern int yylex();
extern int yyparse();
extern FILE* yyin;

void yyerror(const char* s);
%}

%union {
	int inteiro;
	float flutuante;
	char string;
	char* texto;
}

%token<inteiro> T_INT
%token<flutuante> T_FLOAT
%token T_PLUS T_MINUS T_MULTIPLY T_DIVIDE T_LEFT T_RIGHT

%left T_PLUS T_MINUS
%left T_MULTIPLY T_DIVIDE



%token C_LS 
%token C_PS 
%token C_KILL
%token C_MKDIR 										
%token C_RMDIR 								
%token C_CD 											
%token C_TOUCH 									
%token C_IFCONFIG										
%token C_STAR 							
%token C_QUIT
%token C_ID
%token T_NEWLINE 





%type<inteiro> expression
%type<flutuante> mixed_expression
%type<string> comando
%type<texto> C_ID
%start rotshell

%%

rotshell: 
	   | rotshell line										
;

line: T_NEWLINE												{	char diretorio[2023];
																getcwd(diretorio, sizeof(diretorio));
																strcat(diretorio,"$ ");
																printf("Rotshell:~%s",diretorio);
															}
		  | mixed_expression T_NEWLINE 						{ printf("\tResultado = %f\n", $1);}
		  | expression T_NEWLINE 							{ printf("\tResultado = %i\n", $1); } 
		  | comando T_NEWLINE								{	char diretorio[2023];
																getcwd(diretorio, sizeof(diretorio));
																strcat(diretorio,"$ ");
																printf("Rotshell:~%s",diretorio);
															}
		  						
;
	
mixed_expression: T_FLOAT									{ $$ = $1; }
		  | mixed_expression T_PLUS mixed_expression	 	{ $$ = $1 + $3; }
		  | mixed_expression T_MINUS mixed_expression	 	{ $$ = $1 - $3; }
		  | mixed_expression T_MULTIPLY mixed_expression 	{ $$ = $1 * $3; }
		  | mixed_expression T_DIVIDE mixed_expression	 	{ $$ = $1 / $3; }
		  | T_LEFT mixed_expression T_RIGHT		 			{ $$ = $2; }
		  | expression T_PLUS mixed_expression	 	 		{ $$ = $1 + $3; }
		  | expression T_MINUS mixed_expression	 	 		{ $$ = $1 - $3; }
		  | expression T_MULTIPLY mixed_expression 	 		{ $$ = $1 * $3; }
		  | expression T_DIVIDE mixed_expression	 		{ $$ = $1 / $3; }
		  | mixed_expression T_PLUS expression	 	 		{ $$ = $1 + $3; }
		  | mixed_expression T_MINUS expression	 	 		{ $$ = $1 - $3; }
		  | mixed_expression T_MULTIPLY expression 	 		{ $$ = $1 * $3; }
		  | mixed_expression T_DIVIDE expression	 		{ $$ = $1 / $3; }
		  | expression T_DIVIDE expression		 			{ $$ = $1 / (float)$3; }
		  
;

expression: T_INT								{ $$ = $1; }
		  | expression T_PLUS expression		{ $$ = $1 + $3; }
		  | expression T_MINUS expression		{ $$ = $1 - $3; }
		  | expression T_MULTIPLY expression	{ $$ = $1 * $3; }
		  | T_LEFT expression T_RIGHT			{ $$ = $2; }
;



comando:  C_LS 									{ $$ = system("/bin/ls"); }
		| C_PS									{ $$ = system("/bin/ps"); }
		| C_KILL expression						{ char comando[1024]; 
												  char texto[1024];
												  snprintf (comando, sizeof(comando), "/bin/kill %d\n", $2);
												  snprintf (texto, sizeof(texto), "processo %d finalizado\n", $2);
												  printf("%s", texto);
												  $$ = system(comando);
												}
		| C_MKDIR C_ID 							{ char comando[1024] = "/bin/mkdir "; 
												  $$ = system(strcat(comando,$2)); 
												}
		| C_RMDIR C_ID 							{ char comando[1024] = "/bin/rmdir "; 	
												  $$ = system(strcat(comando,$2)); 
												}
		| C_CD C_ID 							{ char comando[2048];
												  int erro;
												  int aux = strcmp("..",$2);
												  if(aux == 0){
												  	erro = chdir($2);
												  }else{
												  	getcwd(comando, sizeof(comando));
	   											  	strcat(comando,"/");
	   											  	strcat(comando,$2);
	   											  	erro = chdir(comando);
	   											  }
	   											  if(erro != 0){
													printf("Diretorio %s nao encontrado\n",$2);
													system("/bin/ls");
	   											  }
	   											}
		| C_TOUCH C_ID 							{ char comando[1024] = "/bin/touch "; 	
												  $$ = system(strcat(comando,$2)); 
												}
		| C_IFCONFIG 							{ $$ = system("ifconfig"); }
		| C_STAR C_ID 							{ printf("Teste C_STAR ID\n"); }
		| C_QUIT T_NEWLINE 						{ printf("Fim do RotShell!\n"); exit(0); }
;

%%

int main() {
	yyin = stdin;

	do { 
		yyparse();
	} while(!feof(yyin));

	return 0;
}

void yyerror(const char* s) {
	fprintf(stderr, "comando invalido: %s\n", s);
	exit(1);
}
