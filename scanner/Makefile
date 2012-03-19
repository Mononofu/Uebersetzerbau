all: lexer.c lexer.l
	gcc lexer.c -o scanner -ll

lexer.c: 
	lex -t lexer.l > lexer.c

clean:
	rm -f lexer.c lexer
