%{
#include "oxout.tab.h"
%}

%option noyywrap

hexnumber				[0-9][0-9a-fA-F]*
decnumber				&([0-9]+)
comment					\(\*([^*]|\**[^\*\)])*\*+\)
whitespace			[\n\t ]
identifier			[a-zA-Z_][0-9a-zA-Z_]*

%%

"end"						return (T_END);
"return"				return (T_RETURN);
"goto"					return (T_GOTO);
"if"						return (T_IF);
"then"					return (T_THEN);
"var"						return (T_VAR);
"not"						return (T_NOT);
"and"						return (T_AND);
"=<"						return (T_LEQ);
";"							return(';');
"("							return ('(');
")"							return (')');
","							return (',');
":"							return (':');
"+"							return ('+');
"-"							return ('-');
"="							return ('=');
"*"							return ('*');
"#"							return ('#');
{comment}				;
{decnumber}			return (T_NUM);  @{ @T_NUM.val@ = atol(yytext+1); @} 
{hexnumber}			return (T_NUM);  @{ unsigned long hex = 0; sscanf(yytext, "%X", &hex); @T_NUM.val@ = hex; @} 
{identifier}		return (T_ID);  @{ @T_ID.name@ = strdup(yytext); @} 
{whitespace}		;
.								printf("Lexical error.\n"); exit(1);
