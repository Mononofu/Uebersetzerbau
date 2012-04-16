/* declarations */
%{
#include <stdlib.h>
#include <assert.h>
#include "parser.h"
%}

%token T_ID T_NUM T_END T_RETURN T_GOTO T_IF T_THEN T_VAR T_NOT T_AND T_LEQ
%start Program


%%
/* rules */

Program: Funcdef ';'
       | Program Program 
       |
       ;  
 
Funcdef: T_ID '(' Pars ')' Stats T_END  /* Funktionsdefinition */  
       ;  
 
Pars: T_ID                            /* Parameterdefinition */  
    |
    | Pars ',' T_ID ','
    | Pars ',' T_ID 
    ;  
 
Stats: Labeldef Stat ';' 
     | Stats Stats
     |
     ;  
 
Labeldef: T_ID ':'                    /* Labeldefinition */  
        |
        | T_ID ':' Labeldef
        ;  
 
Stat: T_RETURN Expr  
    | T_GOTO T_ID  
    | T_IF Expr T_THEN Stats T_END  
    | T_VAR T_ID '=' Expr               /* Variablendefinition */  
    | Lexpr '=' Expr                /* Zuweisung */  
    | Term  
    |
    ;  
 
Lexpr: T_ID        /* schreibender Variablenzugriff */  
     | '*' Unary /* schreibender Speicherzugriff */  
     ;  
 
Expr: Unary  
    | Expr '+' Term  
    | Expr '*' Term
    | Expr T_AND Term 
    | Term T_LEQ Term 
    | Term '#'  Term 
    ;  
 
Unary: T_NOT Unary 
     | '-' Unary
     | '*' Unary   /* lesender Speicherzugriff */  
     | Term  
     ;  
 
Term: '(' Expr ')'  
    | T_NUM  
    | T_ID                               /* Variablenverwendung */  
    | T_ID '(' Args ')'                  /* Funktionsaufruf */  
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

int main(voT_ID)
{
    yyparse();
    return 0;
}
