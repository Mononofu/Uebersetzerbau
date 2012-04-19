all: parser.o lexer.o symbols.o
	gcc -ansi -pedantic -o ag lexer.o parser.o symbols.o -lfl

oxout.y oxout.l: parser.y lexer.l
	ox parser.y lexer.l

lexer.c: oxout.l
	flex -t oxout.l > lexer.c

lexer.o: lexer.c
	gcc -c lexer.c

symbols.o: symbols.c symbols.h
	gcc -c -ansi -pedantic -Wall symbols.c -D_GNU_SOURCE

parser.c oxout.tab.h: oxout.y
	bison -vd oxout.y
	mv oxout.tab.c parser.c

parser.o: parser.c
	gcc -c -ansi -pedantic parser.c

clean:
	rm -f lexer.c ag *.o *.output *.tab.h parser.c oxout.*