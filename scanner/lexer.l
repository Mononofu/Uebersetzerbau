hexnumber				[0-9][0-9a-fA-F]+
decnumber				&[0-9]+
comment					\(\*.+?\*\)

%%

{hexnumber}			printf("num %s", yytext);
