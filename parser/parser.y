/* declarations */
%{
#include <stdlib.h>
#include <assert.h>
#include "parser.h"
%}

%token ID NUM END T_RETURN T_GOTO T_IF T_THEN T_VAR T_NOT T_AND
%start Program


%%
/* rules */

Program: Funcdef ';'
       | Program Program 
       |
       ;  
 
Funcdef: ID '(' Pars ')' Stats END  /* Funktionsdefinition */  
       ;  
 
Pars: ID                            /* Parameterdefinition */  
    |
    | Pars ',' ID 
    ;  
 
Stats: Labeldef Stat ';' 
     | Stats Stats
     ;  
 
Labeldef: ID ':'                    /* Labeldefinition */  
        |
        | ID ':' Labeldef
        ;  
 
Stat: T_RETURN Expr  
    | T_GOTO ID  
    | T_IF Expr T_THEN Stats END  
    | T_VAR ID '=' Expr               /* Variablendefinition */  
    | Lexpr '=' Expr                /* Zuweisung */  
    | Term  
    ;  
 
Lexpr: ID        /* schreibender Variablenzugriff */  
     | '*' Unary /* schreibender Speicherzugriff */  
     ;  
 
Expr: Unary  
    | Expr '+' Term  
    | Expr '*' Term
    | Expr T_AND Term 
    | Term '=' '<' Term 
    | Term '#'  Term 
    ;  
 
Unary: T_NOT Unary 
     | '-' Unary
     | '*' Unary   /* lesender Speicherzugriff */  
     | Term  
     ;  
 
Term: '(' Expr ')'  
    | NUM  
    | ID                               /* Variablenverwendung */  
    | ID '(' Args ')'                  /* Funktionsaufruf */  
    ;

Args:
    | Expr
    | Args ',' Expr 
    ;

%%
/* programs */

int yyerror(char *e)
{
    printf("Parser error: '%s'...\n", e);
    exit(2);
}

int main(voID)
{
    yyparse();
    return 0;
}
