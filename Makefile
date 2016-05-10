all: shell

bison.tab.c bison.tab.h:	bison.y
	bison -d bison.y

lex.yy.c: flex.lex bison.tab.h
	flex flex.lex

shell: lex.yy.c bison.tab.c bison.tab.h
	gcc -o rotshell bison.tab.c lex.yy.c -lfl
	./rotshell

clean:
	rm rotshell bison.tab.c lex.yy.c bison.tab.h
