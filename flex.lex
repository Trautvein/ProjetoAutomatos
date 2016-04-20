%{ 
 #include <stdio.h> 
 
%} 
%option noyywrap 
%% 
[ \t\n]         ; 
[0-9]+\.[0-9]+  { printf("Found a floating-point number: %s", yytext); } 
[0-9]+          { printf("Found an integer: %s", yytext); } 

ls		{system("/bin/ls");} 
ps		{system("/bin/ps");}

%% 
int main(int i, char** c) { 
 yylex(); 
}
