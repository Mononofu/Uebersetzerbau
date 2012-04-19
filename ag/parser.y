/* declarations */
%{
#include <stdlib.h>
#include <assert.h>
%}

%token T_ID T_NUM T_END T_RETURN T_GOTO T_IF T_THEN T_VAR T_NOT T_AND T_LEQ
%start Program

@autoinh symbols

@attributes {int val;} T_NUM
@attributes {char *name;} T_ID


%%
/* rules */

Program: Program Funcdef ';'
       |
       ;  
 
Funcdef: T_ID '(' Pars ')' Stats T_END  /* Funktionsdefinition */  
       ;  
 
Pars:                               /* Parameterdefinition */  
    | T_ID  
    | Pars ',' T_ID ','
    | Pars ',' T_ID 
    ;  
 
Stats: 
     | Stats Labeldef Stat ';' 
     ;  
 
Labeldef:                   /* Labeldefinition */  
        | Labeldef T_ID ':' 
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
    | PlusExpr  
    | MultExpr
    | AndExpr
    | Term T_LEQ Term 
    | Term '#'  Term 
    ;  

PlusExpr: Term '+' Term
        | PlusExpr '+' Term
        ;

MultExpr: Term '*' Term
        | MultExpr '*' Term
        ;

AndExpr: Term T_AND Term
        | AndExpr T_AND Term
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

extern int yylineno;
int yyerror(char *e)
{
    printf("Parser error: '%s'..., line %d\n", e, yylineno);
    exit(2);
}

int main(void)
{
    yyparse();
    return 0;
}
