%option noyywrap

hexnumber				[0-9][0-9a-fA-F]+
decnumber				&([0-9]+)
comment					\(\*[^\*]+\*\)
specialchar			[;\(\),:=\*\-\+\#]
whitespace			[\n\t ]
identifier			[a-zA-Z_][0-9a-zA-Z_]*

%%

"end"						|
"return"				|
"goto"					|
"if"						|
"then"					|
"var"						|
"not"						|
"and"						|
"=<"						|
{specialchar}		printf("%s\n", yytext);
{comment}				;
{hexnumber}			{ unsigned int hex = 0;
									sscanf(yytext, "%X", &hex);
									printf("num %d\n", hex); }
{decnumber}			printf("num %d\n", atoi(yytext+1));
{identifier}		printf("ident %s\n", yytext);
{whitespace}		;
.								printf("Lexical error.\n"); exit(1);
