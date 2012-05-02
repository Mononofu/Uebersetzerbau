/* declarations */
%{
#include <stdlib.h>
#include "symbols.h"
%}

%token T_ID T_NUM T_END T_RETURN T_GOTO T_IF T_THEN T_VAR T_NOT T_AND T_LEQ
%start Program

@autoinh symbols

@attributes {int val;} T_NUM
@attributes {char *name;} T_ID
/* @attributes { struct symbol_t *vars; struct symbol_t *labels; } Funcdef */
@attributes { struct symbol_t *vars; } Pars Term Expr AndExpr Lexpr Unary PlusExpr MultExpr Args
@attributes { struct symbol_t *in_vars; struct symbol_t *out_vars; struct symbol_t *vars; struct symbol_t *in_labels; struct symbol_t *out_labels; struct symbol_t *labels; } Stat
@attributes { struct symbol_t *in_vars; struct symbol_t *out_vars; struct symbol_t *in_labels; struct symbol_t *out_labels; } Stats
@attributes { struct symbol_t *in; struct symbol_t *out; struct symbol_t *vars; } Labeldef

@traversal @postorder t

%%
/* rules */

Program: Program Funcdef ';'
       |
       ;  
 
Funcdef: T_ID '(' Pars ')' Stats T_END  /* Funktionsdefinition */  
        @{ 
            @i @Stats.in_vars@ = @Pars.vars@;
            @i @Stats.in_labels@ = NULL; 
        @}

       | T_ID '(' ')' Stats T_END
        @{ 
            @i @Stats.in_vars@ = NULL;
            @i @Stats.in_labels@ = NULL; 
        @}

       | T_ID '(' Pars ',' ')' Stats T_END
        @{ 
            @i @Stats.in_vars@ = @Pars.vars@;
            @i @Stats.in_labels@ = NULL; 
        @}
       ;  
 
Pars: T_ID                           /* Parameterdefinition */  
    @{
        @i @Pars.vars@ = table_add_symbol(NULL, @T_ID.name@, SYMBOL_TYPE_VAR, 1);
    @}
    | Pars ',' T_ID 
    @{
        @i @Pars.0.vars@ = table_add_symbol(@Pars.1.vars@, @T_ID.name@, SYMBOL_TYPE_VAR, 1);
    @}
    ;  
 
Stats: 
    @{
        @i @Stats.out_labels@ = @Stats.in_labels@; 
        @i @Stats.out_vars@ = @Stats.in_vars@;
    @}

     | Labeldef Stat ';' Stats
    @{
        @i @Labeldef.in@ = @Stats.0.in_labels@;
        @i @Labeldef.vars@ = @Stats.0.in_vars@;

        @i @Stat.in_vars@ = @Stats.0.in_vars@;
        @i @Stat.in_labels@ = @Labeldef.out@;
        @i @Stat.vars@ = @Stats.0.out_vars@;
        @i @Stat.labels@ = @Stats.0.out_labels@;

        @i @Stats.1.in_vars@ = @Stat.out_vars@;
        @i @Stats.1.in_labels@ = @Stat.out_labels@;

        @i @Stats.0.out_labels@ = @Stats.1.out_labels@;
        @i @Stats.0.out_vars@ = @Stats.1.out_vars@;
    @}

     ;  
 
Labeldef:                   /* Labeldefinition */  
        @{
            @i @Labeldef.out@ = @Labeldef.in@;
        @}

        | Labeldef T_ID ':' 
        @{
            @i @Labeldef.1.in@ = table_add_symbol(@Labeldef.0.in@, @T_ID.name@, SYMBOL_TYPE_LABEL, 1);
            @i @Labeldef.1.vars@ = @Labeldef.0.vars@;
            @i @Labeldef.0.out@ = @Labeldef.1.out@;

            @t check_not_variable(@Labeldef.0.vars@, @T_ID.name@);
        @}
        ;  
 
Stat: T_RETURN Expr  
    @{
        @i @Expr.vars@ = @Stat.vars@; 
        @i @Stat.out_vars@ = @Stat.in_vars@;
        @i @Stat.out_labels@ = @Stat.in_labels@;
    @}

    | T_GOTO T_ID  
    @{ 
        @t check_label_exists(@Stat.labels@, @T_ID.name@);
        @i @Stat.out_vars@ = @Stat.in_vars@;
        @i @Stat.out_labels@ = @Stat.in_labels@;
    @}

    | T_IF Expr T_THEN Stats T_END  
    @{
        @i @Expr.vars@ = @Stat.vars@; 

        @i @Stats.in_vars@ = clone_table(@Stat.vars@);
        @i @Stats.in_labels@ = @Stat.in_labels@; 

        @i @Stat.out_vars@ = @Stat.in_vars@;
        @i @Stat.out_labels@ = @Stats.out_labels@;
    @}

    | T_VAR T_ID '=' Expr               /* Variablendefinition */  
    @{
        @i @Expr.vars@ = @Stat.vars@; 
        @i @Stat.out_vars@ = table_add_symbol(@Stat.in_vars@, @T_ID.name@, SYMBOL_TYPE_VAR, 1);
        @i @Stat.out_labels@ = @Stat.in_labels@;

        @t check_not_label(@Stat.in_labels@, @T_ID.name@);
    @}

    | Lexpr '=' Expr                /* Zuweisung */  
    @{
        @i @Expr.vars@ = @Stat.vars@; 
        @i @Lexpr.vars@ = @Stat.vars@;  
        @i @Stat.out_vars@ = @Stat.in_vars@;
        @i @Stat.out_labels@ = @Stat.in_labels@;
    @}

    | Term  
    @{
        @i @Term.vars@ = @Stat.vars@;
        @i @Stat.out_vars@ = @Stat.in_vars@;
        @i @Stat.out_labels@ = @Stat.in_labels@;
    @}

    |
    @{
        @i @Stat.out_vars@ = @Stat.in_vars@;
        @i @Stat.out_labels@ = @Stat.in_labels@;
    @}
    ;  
 
Lexpr: T_ID        /* schreibender Variablenzugriff */  
     @{ @t check_variable_exists(@Lexpr.vars@, @T_ID.name@); @}

     | '*' Unary /* schreibender Speicherzugriff */  
     @{ @i @Unary.vars@ = @Lexpr.vars@; @}
     ;  
 
Expr: Unary  
     @{ @i @Unary.vars@ = @Expr.vars@; @}

    | PlusExpr  
     @{ @i @PlusExpr.vars@ = @Expr.vars@; @}

    | MultExpr
     @{ @i @MultExpr.vars@ = @Expr.vars@; @}

    | AndExpr
     @{ @i @AndExpr.vars@ = @Expr.vars@; @}

    | Term T_LEQ Term 
     @{ 
        @i @Term.0.vars@ = @Expr.vars@; 
        @i @Term.1.vars@ = @Expr.vars@; 
    @}

    | Term '#'  Term 
     @{ 
        @i @Term.0.vars@ = @Expr.vars@; 
        @i @Term.1.vars@ = @Expr.vars@; 
    @}
    ;  

PlusExpr: Term '+' Term
         @{ 
            @i @Term.0.vars@ = @PlusExpr.vars@; 
            @i @Term.1.vars@ = @PlusExpr.vars@; 
         @}

        | PlusExpr '+' Term
         @{ 
            @i @Term.vars@ = @PlusExpr.0.vars@; 
            @i @PlusExpr.1.vars@ = @PlusExpr.0.vars@; 
         @}
        ;

MultExpr: Term '*' Term
         @{ 
            @i @Term.0.vars@ = @MultExpr.vars@; 
            @i @Term.1.vars@ = @MultExpr.vars@; 
         @}

        | MultExpr '*' Term
         @{ 
            @i @Term.vars@ = @MultExpr.0.vars@; 
            @i @MultExpr.1.vars@ = @MultExpr.0.vars@; 
         @}
        ;

AndExpr: Term T_AND Term
        @{
            @i @Term.0.vars@ = @AndExpr.vars@;
            @i @Term.1.vars@ = @AndExpr.vars@;
        @} 

        | AndExpr T_AND Term
        @{
            @i @Term.vars@ = @AndExpr.0.vars@;
            @i @AndExpr.1.vars@ = @AndExpr.0.vars@;
        @} 
        ;
 
Unary: T_NOT Unary 
        @{ @i @Unary.1.vars@ = @Unary.0.vars@; @}

     | '-' Unary
        @{ @i @Unary.1.vars@ = @Unary.0.vars@; @}

     | '*' Unary   /* lesender Speicherzugriff */  
        @{ @i @Unary.1.vars@ = @Unary.0.vars@; @}

     | Term 
    @{ @i @Term.vars@ = @Unary.vars@; @} 
     ;  
 
Term: '(' Expr ')'  
    @{ @i @Expr.vars@ = @Term.vars@; @} 

    | T_NUM  
    | T_ID                               /* Variablenverwendung */  
    @{ @t check_variable_exists(@Term.vars@, @T_ID.name@); @}

    | T_ID '(' Args ')'                  /* Funktionsaufruf */  
    @{ @i @Args.vars@ = @Term.vars@; @} 

    | T_ID '(' Args ',' ')' 
    @{ @i @Args.vars@ = @Term.vars@; @} 

    | T_ID '(' ')' 
    ;

Args: Expr
    @{ @i @Expr.vars@ = @Args.vars@; @} 
    | Args ',' Expr 
    @{
        @i @Expr.vars@ = @Args.0.vars@;
        @i @Args.1.vars@ = @Args.0.vars@;
    @} 

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
