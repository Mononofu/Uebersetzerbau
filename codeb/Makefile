all: codeb

codeb: parser.o lexer.o symbols.o helpers.o tree.o code.o
	gcc -ansi -pedantic lexer.o parser.o symbols.o helpers.o tree.o code.o -lfl -o codeb -g

oxout.y oxout.l: parser.y lexer.l
	ox parser.y lexer.l

lexer.c: oxout.l
	flex -t oxout.l > lexer.c

lexer.o: lexer.c
	gcc -c lexer.c -g

symbols.o: symbols.c symbols.h
	gcc -c -ansi -pedantic -Wall symbols.c -D_GNU_SOURCE -g

helpers.o: helpers.c helpers.h
	gcc -c -ansi -pedantic -Wall helpers.c -g

parser.c oxout.tab.h: oxout.y
	bison -vd oxout.y
	mv oxout.tab.c parser.c

parser.o: parser.c
	gcc -c -ansi -pedantic parser.c -g

tree.o: tree.c tree.h
	gcc -c -ansi -pedantic -Wall tree.c -g

code.o: code.c tree.h
	gcc -c -ansi code.c -g

code.c: code.bfe
	bfe < code.bfe | iburg > code.c

clean:
	rm -f lexer.c codeb *.o *.output *.tab.h parser.c oxout.* code.c core