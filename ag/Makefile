all: parser.o lexer.o 
	gcc -o ag lexer.o parser.o -lfl

oxout.y oxout.l: parser.y lexer.l
	ox parser.y lexer.l

lexer.c: oxout.l
	flex -t oxout.l > lexer.c

lexer.o: lexer.c
	gcc -c lexer.c

parser.c oxout.tab.h: oxout.y
	bison -vd oxout.y
	mv oxout.tab.c parser.c

parser.o: parser.c
	gcc -c parser.c

clean:
	rm -f lexer.c ag *.o *.output *.tab.h parser.c oxout.*