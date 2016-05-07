%{

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <unistd.h>

extern int yylex();
extern int yyparse();
extern FILE* yyin;


void inicio(){
		char diretorio[2023];
		getcwd(diretorio, sizeof(diretorio));
		strcat(diretorio,"$ ");
		printf("Rotshell:~%s",diretorio);
}

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
%token C_PWD
%token C_KILL
%token C_MKDIR 										
%token C_RMDIR 								
%token C_CD 											
%token C_TOUCH 									
%token C_IFCONFIG										
%token C_START 							
%token C_QUIT
%token C_ID
%token C_HELP
%token C_CLEAR
%token T_NEWLINE 





%type<inteiro> expression
%type<flutuante> mixed_expression
%type<string> comando
%type<texto> C_ID
%start rotshell

%%

rotshell: 													{ 
		  														
		  													}
	   | rotshell line										
;

line: T_NEWLINE												{ inicio();}
		  | mixed_expression T_NEWLINE 						{ printf("\tResultado = %f\n", $1); inicio();}
		  | expression T_NEWLINE 							{ printf("\tResultado = %i\n", $1); inicio();} 
		  | comando T_NEWLINE								{ inicio();}
		  						
;
	
mixed_expression: T_FLOAT											{ $$ = $1; }
		  | mixed_expression T_PLUS mixed_expression	 			{ $$ = $1 + $3; }
		  | mixed_expression T_MINUS mixed_expression	 			{ $$ = $1 - $3; }
		  | mixed_expression T_MULTIPLY mixed_expression 			{ $$ = $1 * $3; }
		  | mixed_expression T_DIVIDE mixed_expression	 			{ $$ = $1 / $3; }
		  | T_LEFT mixed_expression T_RIGHT		 					{ $$ = $2; }
		  | expression T_PLUS mixed_expression	 	 				{ $$ = $1 + $3; }
		  | expression T_MINUS mixed_expression	 	 				{ $$ = $1 - $3; }
		  | expression T_MULTIPLY mixed_expression 	 				{ $$ = $1 * $3; }
		  | expression T_DIVIDE mixed_expression	 				{ $$ = $1 / $3; }
		  | mixed_expression T_PLUS expression	 	 				{ $$ = $1 + $3; }
		  | mixed_expression T_MINUS expression	 	 				{ $$ = $1 - $3; }
		  | mixed_expression T_MULTIPLY expression 	 				{ $$ = $1 * $3; }
		  | mixed_expression T_DIVIDE expression	 				{ $$ = $1 / $3; }
		  | expression T_DIVIDE expression		 					{ $$ = $1 / (float)$3; }
		  
;

expression: T_INT												{ $$ = $1; }
		  | expression T_PLUS expression						{ $$ = $1 + $3; }
		  | expression T_MINUS expression						{ $$ = $1 - $3; }
		  | expression T_MULTIPLY expression					{ $$ = $1 * $3; }
		  | T_LEFT expression T_RIGHT							{ $$ = $2; }
;




comando:  C_LS 									{ $$ = system("/bin/ls"); }
		| C_LS 	C_ID							{ printf("ls: não é possível acessar %s: Arquivo ou diretório não encontrado\n",$2); }
		
		| C_LS T_MINUS C_ID						{ char comando[1024] = "/bin/ls -"; 	
												  $$ = system(strcat(comando,$3)); 
												}					
		| C_PS									{ $$ = system("/bin/ps"); }
		| C_PS	C_ID							{ $$ = system("/bin/ps"); }
		| C_PWD									{ $$ = system("/bin/pwd"); }
		| C_PWD	C_ID							{ $$ = system("/bin/pwd"); }
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
		| C_MKDIR 	 							{ printf("mkdir: falta operando\nTry 'help' for more information.\n"); }										
		| C_RMDIR C_ID 							{ char comando[1024] = "/bin/rmdir "; 	
												  $$ = system(strcat(comando,$2)); 
												}
		| C_RMDIR								{ printf("rmdir: falta operando\nTry 'help' for more information.\n"); }
		| C_CD									{ int erro = chdir("/home");
												  if(erro != 0){
													printf("Diretorio nao encontrado\n");
													system("/bin/ls");
	   											  }
												}	
		| C_CD C_ID 							{ char comando[2048];
												  int erro;
												  int aux = strcmp("..",$2);
												  int auxx = strcmp("~",$2);
												  if(aux == 0){
												  	erro = chdir($2);
												  }else if(auxx == 0){
												  	erro = chdir("/home");
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
		| C_START C_ID 							{ strcat($2,"&");
												  $$ = system($2);  
												}
		| C_HELP								{	printf("\n( ls ) ------------------Lista o conteúdo do diretório atual\n");
													printf("( ls -l ) ---------------Mostra propriedades\n");
													printf("( ps ) ------------------Lista todos os processos do usuário\n");
													printf("( pwd ) -----------------Mostra o diretorio atual \n");
													printf("( kill ) ----------------Fecha processo\n");
													printf("( mkdir ) ---------------Cria um diretorio\n");
													printf("( rmdir ) ---------------Remove o diretório \n");
													printf("( cd /Diretorio ) -------Torna o diretório id como atual\n");
													printf("( cd ~ ou cd ) ----------Vai para a pasta do usuário\n");
													printf("( cd .. ) ---------------Diretório acima\n");
													printf("( touch ) ---------------Cria um arquivo com o nome id ou atualiza um arquivoid\n");
													printf("( ifconfig ) ------------Exibe as informações de todas as interfaces de rede do sistema\n");
													printf("( start ) ---------------Invoca a execução do programa id\n");
													printf("( help ) ----------------Mostra informacoes sobre os comandos\n");
													printf("( clear )----------------Limpa a tela\n");
													printf("( quit ) ----------------Encerra o shell\n\n");
												}
		| C_CLEAR 								{ system("clear");}										
		| C_QUIT T_NEWLINE 						{ printf("Fim do RotShell!\n\n"); exit(0); }
;

%%

int main() {
	yyin = stdin;
	
		
	
		inicio();
  													
		
	
		
	
	
																
	do { 
		yyparse();
	} while(!feof(yyin));

	return 0;
}

void yyerror(const char* s) {
	fprintf(stderr, "Comando invalido: %s\n", s);
	
		
}
