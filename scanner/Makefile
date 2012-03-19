all: lexer.c
	gcc lexer.c -o lexer

lexer.c: 
	flex -t lexer.l > lexer.c
	
clean:
	rm -f lexer.c lexer
