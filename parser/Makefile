all: lexer.c lexer.l
	gcc lexer.c -o scanner -ll

lexer.c: lexer.l
	lex -t lexer.l > lexer.c

clean:
	rm -f lexer.c scanner
