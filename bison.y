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
	int ival;
	float fval;
	char string;
	char* stringp;
}

%token<ival> T_INT
%token<fval> T_FLOAT
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





%type<ival> expression
%type<fval> mixed_expression
%type<string> comando
%type<stringp> C_ID
%start rotshell

%%

rotshell: 
	   | rotshell line
;

line: T_NEWLINE
		  | mixed_expression T_NEWLINE 						{ printf("\tResultado = %f\n", $1);}
		  | expression T_NEWLINE 							{ printf("\tResultado = %i\n", $1); } 
		  | comando T_NEWLINE								
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

expression: T_INT											{ $$ = $1; }
		  | expression T_PLUS expression					{ $$ = $1 + $3; }
		  | expression T_MINUS expression					{ $$ = $1 - $3; }
		  | expression T_MULTIPLY expression				{ $$ = $1 * $3; }
		  | T_LEFT expression T_RIGHT						{ $$ = $2; }
;

comando:  C_LS 												{ $$ = system("/bin/ls"); }
		| C_PS 												{ $$ = system("/bin/ps"); }
		| C_KILL expression									{   char comando[1024]; 
																char buffer[1024];
																snprintf (comando, sizeof(comando), "/bin/kill %d\n", $2);
																snprintf (buffer, sizeof(buffer), "processo %d finalizado\n", $2);
																printf("%s", buffer);
																$$ = system(comando);
															}
		| C_MKDIR C_ID										{   char comando[1024] = "/bin/mkdir "; 
																printf("%s %s", comando,$2);
																
															}
		| C_RMDIR C_ID										{ 	char comando[1024] = "/bin/rmdir "; 	
																$$ = system(strcat(comando,$2)); 
															}
		| C_CD C_ID											{ printf("Teste C_CD ID\n"); }
		| C_TOUCH C_ID										{ printf("Teste C_TOUCH ID\n"); }
		| C_IFCONFIG										{ $$ = system("ifconfig"); }
		| C_STAR C_ID 										{ printf("Teste C_STAR ID\n"); }
		| C_QUIT T_NEWLINE 									{ printf("Fim do RotShell!\n"); exit(0); }
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
