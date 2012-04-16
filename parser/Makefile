all: parser.o lexer.o 
	gcc -o parser lexer.o parser.o -lfl

lexer.c: lexer.l
	flex -t lexer.l > lexer.c

lexer.o: lexer.c
	gcc -c lexer.c

parser.c oxout.tab.h: parser.y
	bison -vd parser.y
	mv parser.tab.c parser.c

parser.o: parser.c
	gcc -c parser.c

clean:
	rm -f lexer.c parser *.o *.output *.tab.h parser.c