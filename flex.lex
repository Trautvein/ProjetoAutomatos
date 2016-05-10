%{ 

	#include <stdio.h>
	#define YY_DECL int yylex()
	#include "bison.tab.h" 
 
%} 


%option noyywrap

 
%% 


[0-9]+\.[0-9]+ 	{yylval.flutuante = atof(yytext); return T_FLOAT;}
[0-9]+			{yylval.inteiro = atoi(yytext); return T_INT;}
"+"			{return T_PLUS;}
"-"			{return T_MINUS;}
"*"			{return T_MULTIPLY;}
"/"			{return T_DIVIDE;}
"("			{return T_LEFT;}
")"			{return T_RIGHT;}



 



"ls"			{return C_LS;}//--------Lista o conteúdo do diretório atual
"ps"			{return C_PS;}//--------Lista todos os processos do usuário
"pwd"			{return C_PWD;}//-------Mostra o diretorio atual
"kill"			{return C_KILL;}//------Fecha processo
"mkdir"			{return C_MKDIR;}//-----Cria um diretorio
"rmdir" 		{return C_RMDIR;}//-----Remove o diretório 
"cd"			{return C_CD;}//--------Torna o diretório id como atual
"touch"			{return C_TOUCH;}//-----Cria um arquivo com o nome id
"ifconfig"		{return C_IFCONFIG;}//--Exibe as informações de todas as interfaces de rede do sistema
"start"			{return C_START;}//-----Invoca a execução do programa id
"help"			{return C_HELP;}//------Mostra informacoes sobre os comandos
"clear"			{return C_CLEAR;}//-----Limpa a tela
"quit"			{return C_QUIT;}//------Encerra o shell





[ \t]        								;//---------------------Iguinora	
\n											{return T_NEWLINE;}//---Quebra linha
[~a-zA-Z0-9\.()_/]*							{yylval.texto = (yytext); return C_ID;}//--------Entrada tipo String


%%



