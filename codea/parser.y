/* declarations */
%{
#include <stdlib.h>
#include "tree.h"
#include "symbols.h"
%}

%token T_ID T_NUM T_END T_RETURN T_GOTO T_IF T_THEN T_VAR T_NOT T_AND T_LEQ
%start File

@autoinh symbols

@attributes {long val;} T_NUM
@attributes {char *name;} T_ID
/* @attributes { struct symbol_t *vars; struct symbol_t *labels; } Funcdef */
@attributes { struct symbol_t *vars; int num_pars; } Pars
@attributes { struct symbol_t *vars; struct treenode* node; int immediate; } Term Expr AndExpr Lexpr Unary PlusExpr MultExpr  Args
@attributes { struct symbol_t *in_vars; struct symbol_t *out_vars; struct symbol_t *vars; struct symbol_t *in_labels; struct symbol_t *out_labels; struct symbol_t *labels; struct treenode* node; } Stat
@attributes { struct symbol_t *in_vars; struct symbol_t *out_vars; struct symbol_t *in_labels; struct symbol_t *out_labels; struct symbol_t *labels; struct treenode* node; } Stats
@attributes { struct symbol_t *in; struct symbol_t *out; struct symbol_t *vars; } Labeldef

@traversal @postorder check
@traversal @preorder reg
@traversal @preorder count
@traversal @postorder codegen

%%
/* rules */

File: Program
        @{
            @codegen @revorder(1) printf("\t.text\n");
        @}

Program: Program Funcdef ';'
       |
       ;  
 
Funcdef: T_ID '(' Pars ')' T_END            /* special case for funs without body */
        @{
            @codegen clean_slate();
            @codegen function_header(@T_ID.name@); imm_ret();
        @}
       | T_ID '(' Pars ',' ')' T_END
        @{ 
            @codegen clean_slate();
            @codegen function_header(@T_ID.name@); imm_ret();
        @}
       | T_ID '(' ')' T_END
        @{ 
            @codegen clean_slate();
            @codegen function_header(@T_ID.name@); imm_ret();
        @}

       |T_ID '(' Pars ')' Stats T_END  /* Funktionsdefinition */  
        @{ 
            @codegen clean_slate();
            @i @Stats.in_vars@ = @Pars.vars@;
            @i @Stats.in_labels@ = NULL; 
            @i @Stats.labels@ = @Stats.out_labels@; 

            @codegen @revorder(1) function_header(@T_ID.name@);
        @}

       | T_ID '(' ')' Stats T_END
        @{ 
            @codegen clean_slate();
            @i @Stats.in_vars@ = NULL;
            @i @Stats.in_labels@ = NULL; 
            @i @Stats.labels@ = @Stats.out_labels@; 

            @codegen @revorder(1) function_header(@T_ID.name@);
        @}

       | T_ID '(' Pars ',' ')' Stats T_END
        @{ 
            @codegen clean_slate();
            @i @Stats.in_vars@ = @Pars.vars@;
            @i @Stats.in_labels@ = NULL; 
            @i @Stats.labels@ = @Stats.out_labels@; 

            @codegen @revorder(1) function_header(@T_ID.name@);
        @}
       ;  
 
Pars: T_ID                           /* Parameterdefinition */  
    @{
        @i @Pars.vars@ = table_add_param(NULL, @T_ID.name@, 1);
        @i @Pars.num_pars@ = 1;

        @codegen record_param(1, @T_ID.name@);
    @}
    | Pars ',' T_ID 
    @{
        @i @Pars.0.vars@ = table_add_param(@Pars.1.vars@, @T_ID.name@, @Pars.0.num_pars@);
        @i @Pars.0.num_pars@ = @Pars.1.num_pars@ + 1;

        @codegen record_param(@Pars.0.num_pars@, @T_ID.name@);
    @}
    ;

 
Stats: 
    @{
        @i @Stats.node@ = new_leaf(OP_NOP);
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
        @i @Stat.labels@ = @Stats.0.labels@;

        @i @Stats.1.in_vars@ = @Stat.out_vars@;
        @i @Stats.1.in_labels@ = @Stat.out_labels@;
        @i @Stats.1.labels@ = @Stats.0.labels@; 

        @i @Stats.0.out_labels@ = @Stats.1.out_labels@;
        @i @Stats.0.out_vars@ = @Stats.1.out_vars@;

        @i @Stats.0.node@ = new_node(OP_Stats, @Stat.node@, @Stats.1.node@);
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

            @check check_not_variable(@Labeldef.0.vars@, @T_ID.name@);

            @codegen print_label("", @T_ID.name@, ":\n"); 
        @}
        ;  
 
Stat: T_RETURN Expr  
    @{
        @i @Expr.vars@ = @Stat.vars@; 
        @i @Stat.out_vars@ = @Stat.in_vars@;
        @i @Stat.out_labels@ = @Stat.in_labels@;

        @i @Stat.node@ = new_node(OP_Return, @Expr.node@, (treenode *)NULL);
        
        @reg @Stat.node@->reg = get_next_reg((char *)NULL, 0); @Expr.node@->reg = @Stat.node@->reg;

        @codegen burm_label(@Stat.node@); burm_reduce(@Stat.node@, 1);
    @}

    | T_GOTO T_ID  
    @{ 
        @check check_label_exists(@Stat.labels@, @T_ID.name@);
        @i @Stat.out_vars@ = @Stat.in_vars@;
        @i @Stat.out_labels@ = @Stat.in_labels@;

        @i @Stat.node@ = (treenode *)NULL;

        @codegen print_label("\tjmp ", @T_ID.name@, "\n");
    @}

    | T_IF Expr T_THEN Stats T_END  
    @{
        @i @Expr.vars@ = @Stat.vars@; 

        @i @Stats.in_vars@ = clone_table(@Stat.vars@);
        @i @Stats.in_labels@ = @Stat.in_labels@; 

        @i @Stats.labels@ = @Stat.labels@; 

        @i @Stat.out_vars@ = @Stat.in_vars@;
        @i @Stat.out_labels@ = @Stats.out_labels@;

        @i @Stat.node@ = new_node(OP_IF, @Expr.node@, @Stats.node@);
        @reg @Stat.node@->reg = get_next_reg((char *)NULL, 0); @Expr.node@->reg = @Stat.node@->reg;

        @codegen @revorder(1) burm_label(@Stat.node@); burm_reduce(@Stat.node@, 1);
        @codegen @revorder start_if(@Expr.node@);

        @codegen end_if(@Expr.node@, @Expr.immediate@);
    @}

    | T_VAR T_ID '=' Expr               /* Variablendefinition */  
    @{
        @i @Expr.vars@ = @Stat.vars@; 
        @i @Stat.out_vars@ = table_add_symbol(@Stat.in_vars@, @T_ID.name@, SYMBOL_TYPE_VAR, 1);
        @i @Stat.out_labels@ = @Stat.in_labels@;

        @check check_not_label(@Stat.labels@, @T_ID.name@);

        @i @Stat.node@ = new_node(OP_Assign, new_named_leaf_value(OP_ID, @T_ID.name@, 0, 0), @Expr.node@);

        @count record_var_usage(@T_ID.name@);

        @codegen @revorder(1) burm_label(@Stat.node@); burm_reduce(@Stat.node@, 1);

    @}

    | Lexpr '=' Expr                /* Zuweisung */  
    @{
        @i @Expr.vars@ = @Stat.vars@; 
        @i @Lexpr.vars@ = @Stat.vars@;  
        @i @Stat.out_vars@ = @Stat.in_vars@;
        @i @Stat.out_labels@ = @Stat.in_labels@;

        @i @Stat.node@ = new_node(OP_Assign, @Lexpr.node@, @Expr.node@);

        @codegen @revorder(1) burm_label(@Stat.node@); burm_reduce(@Stat.node@, 1);
    @}

    | Term  
    @{
        @i @Term.vars@ = @Stat.vars@;
        @i @Stat.out_vars@ = @Stat.in_vars@;
        @i @Stat.out_labels@ = @Stat.in_labels@;

        @i @Stat.node@ = (treenode *)NULL;
    @}

    |
    @{
        @i @Stat.out_vars@ = @Stat.in_vars@;
        @i @Stat.out_labels@ = @Stat.in_labels@;

        @i @Stat.node@ = (treenode *)NULL;
    @}
    ;  
 
Lexpr: T_ID        /* schreibender Variablenzugriff */  
     @{ 
        @check check_variable_exists(@Lexpr.vars@, @T_ID.name@); 
        @i @Lexpr.immediate@ = 0;

        @i @Lexpr.node@ = new_named_leaf_value(OP_ID, @T_ID.name@, 0, 0);
    @}

     | '*' Unary /* schreibender Speicherzugriff */  
     @{ 
        @i @Unary.vars@ = @Lexpr.vars@; 
        @i @Lexpr.immediate@ = @Unary.immediate@;

        @i @Lexpr.node@ = @Unary.node@;
    @}
     ;  
 
Expr: Unary  
    @{ 
        @i @Unary.vars@ = @Expr.vars@; 
        @i @Expr.node@ = @Unary.node@;
        @i @Expr.immediate@ = @Unary.immediate@;

        @reg @Unary.node@->reg = @Expr.node@->reg;
    @}

    | PlusExpr  
    @{ 
        @i @PlusExpr.vars@ = @Expr.vars@; 
        @i @Expr.node@ = @PlusExpr.node@;
        @i @Expr.immediate@ = @PlusExpr.immediate@;

        @reg @PlusExpr.node@->reg = @Expr.node@->reg;
    @}

    | MultExpr
    @{ 
        @i @MultExpr.vars@ = @Expr.vars@;
        @i @Expr.node@ = @MultExpr.node@;
        @i @Expr.immediate@ = @MultExpr.immediate@;

        @reg @MultExpr.node@->reg = @Expr.node@->reg;
    @}

    | AndExpr
    @{ 
        @i @AndExpr.vars@ = @Expr.vars@;
        @i @Expr.node@ = @AndExpr.node@;
        @i @Expr.immediate@ = @AndExpr.immediate@;

        @reg @AndExpr.node@->reg = @Expr.node@->reg;
    @}

    | Term T_LEQ Term 
     @{ 
        @i @Term.0.vars@ = @Expr.vars@; 
        @i @Term.1.vars@ = @Expr.vars@; 

        @i @Expr.immediate@ = @Term.0.immediate@ && @Term.1.immediate@;
        @i @Expr.node@ = new_node(OP_LEQ, @Term.0.node@, @Term.1.node@);        

        @reg @Term.0.node@->reg = @Expr.node@->reg; @Term.1.node@->reg = get_next_reg(@Expr.node@->reg, @Expr.node@->skip_reg);
    @}

    | Term '#' Term 
     @{ 
        @i @Term.0.vars@ = @Expr.vars@; 
        @i @Term.1.vars@ = @Expr.vars@; 

        @i @Expr.immediate@ = @Term.0.immediate@ && @Term.1.immediate@;
        @i @Expr.node@ = new_node(OP_NEQ, @Term.0.node@, @Term.1.node@);

        @reg @Term.0.node@->reg = @Expr.node@->reg; @Term.1.node@->reg = get_next_reg(@Expr.node@->reg, @Expr.node@->skip_reg);
    @}
    ;  

PlusExpr: Term '+' Term
         @{ 
            @i @Term.0.vars@ = @PlusExpr.vars@; 
            @i @Term.1.vars@ = @PlusExpr.vars@; 

            @i @PlusExpr.immediate@ = @Term.0.immediate@ && @Term.1.immediate@;
            @i @PlusExpr.node@ = new_node(OP_ADD, @Term.0.node@, @Term.1.node@);

            @reg @Term.0.node@->reg = @PlusExpr.node@->reg; @Term.1.node@->reg = get_next_reg(@PlusExpr.node@->reg, @PlusExpr.node@->skip_reg);
         @}

        | PlusExpr '+' Term
         @{ 
            @i @Term.vars@ = @PlusExpr.0.vars@; 
            @i @PlusExpr.1.vars@ = @PlusExpr.0.vars@; 

            @i @PlusExpr.0.immediate@ = @PlusExpr.1.immediate@ && @Term.immediate@;
            @i @PlusExpr.0.node@ = new_node(OP_ADD, @PlusExpr.1.node@, @Term.node@);

            @reg @Term.node@->reg = @PlusExpr.0.node@->reg; @PlusExpr.1.node@->reg = get_next_reg(@PlusExpr.0.node@->reg, @PlusExpr.node@->skip_reg);
         @}
        ;

MultExpr: Term '*' Term
         @{ 
            @i @Term.0.vars@ = @MultExpr.vars@; 
            @i @Term.1.vars@ = @MultExpr.vars@;

            @i @MultExpr.immediate@ = @Term.0.immediate@ && @Term.1.immediate@;
            @i @MultExpr.node@ = new_node(OP_MUL, @Term.0.node@, @Term.1.node@);

            @reg @Term.0.node@->reg = @MultExpr.node@->reg; @Term.1.node@->reg = get_next_reg(@MultExpr.node@->reg, @MultExpr.node@->skip_reg);
         @}

        | MultExpr '*' Term
         @{ 
            @i @Term.vars@ = @MultExpr.0.vars@; 
            @i @MultExpr.1.vars@ = @MultExpr.0.vars@; 

            @i @MultExpr.0.immediate@ = @MultExpr.1.immediate@ && @Term.immediate@;
            @i @MultExpr.0.node@ = new_node(OP_MUL, @MultExpr.1.node@, @Term.node@);

            @reg @Term.node@->reg = @MultExpr.0.node@->reg; @MultExpr.1.node@->reg = get_next_reg(@MultExpr.0.node@->reg, @MultExpr.node@->skip_reg);
         @}
        ;

AndExpr: Term T_AND Term
        @{
            @i @Term.0.vars@ = @AndExpr.vars@;
            @i @Term.1.vars@ = @AndExpr.vars@;

            @i @AndExpr.immediate@ = @Term.0.immediate@ && @Term.1.immediate@;
            @i @AndExpr.node@ = (@Term.0.node@->op == OP_ID && @Term.1.node@->op == OP_ID && strcmp(@Term.0.node@->name, @Term.1.node@->name) == 0) ? @Term.0.node@ : new_node(OP_AND, @Term.0.node@, @Term.1.node@);

            @reg @Term.0.node@->reg = @AndExpr.node@->reg; @Term.1.node@->reg = get_next_reg(@AndExpr.node@->reg, @AndExpr.node@->skip_reg);
        @} 

        | AndExpr T_AND Term
        @{
            @i @Term.vars@ = @AndExpr.0.vars@;
            @i @AndExpr.1.vars@ = @AndExpr.0.vars@;

            @i @AndExpr.0.immediate@ = @AndExpr.1.immediate@ && @Term.immediate@;
            @i @AndExpr.0.node@ = new_node(OP_AND, @AndExpr.1.node@, @Term.node@);

            @reg @Term.node@->reg = @AndExpr.0.node@->reg; @AndExpr.1.node@->reg = get_next_reg(@AndExpr.0.node@->reg, @AndExpr.node@->skip_reg);            
        @} 
        ;
 
Unary: T_NOT T_NOT Unary 
        @{ 
            @i @Unary.1.vars@ = @Unary.0.vars@; 

            @i @Unary.0.immediate@ = @Unary.1.immediate@;
            @i @Unary.0.node@ = @Unary.1.node@;

            @reg @Unary.1.node@->reg = @Unary.0.node@->reg;
        @}

     | T_NOT Unary 
        @{ 
            @i @Unary.1.vars@ = @Unary.0.vars@; 

            @i @Unary.0.immediate@ = @Unary.1.immediate@;
            @i @Unary.0.node@ = new_node(OP_NOT, @Unary.1.node@, (treenode *) NULL);

            @reg @Unary.1.node@->reg = @Unary.0.node@->reg;
        @}

     | '-' '-' Unary
        @{ 
            @i @Unary.1.vars@ = @Unary.0.vars@; 

            @i @Unary.0.immediate@ = @Unary.1.immediate@;
            @i @Unary.0.node@ = @Unary.1.node@;

            @reg @Unary.1.node@->reg = @Unary.0.node@->reg;
        @}

     | '-' Unary
        @{ 
            @i @Unary.1.vars@ = @Unary.0.vars@; 

            @i @Unary.0.immediate@ = @Unary.1.immediate@;
            @i @Unary.0.node@ = new_node(OP_NEG, @Unary.1.node@, (treenode *) NULL);

            @reg @Unary.1.node@->reg = @Unary.0.node@->reg;
        @}

     | '*' Unary   /* lesender Speicherzugriff */  
        @{ 
            @i @Unary.1.vars@ = @Unary.0.vars@; 

            @i @Unary.0.immediate@ = @Unary.1.immediate@;
            @i @Unary.0.node@ = new_node(OP_ReadMem, @Unary.1.node@, (treenode *) NULL);

            @reg @Unary.1.node@->reg = @Unary.0.node@->reg;
        @}

     | Term 
    @{ 
        @i @Term.vars@ = @Unary.vars@; 

        @i @Unary.node@ = @Term.node@;
        @i @Unary.immediate@ = @Term.immediate@;

        @reg @Term.node@->reg = @Unary.node@->reg;
    @} 
     ;  
 
Term: '(' Expr ')'  
    @{ 
        @i @Expr.vars@ = @Term.vars@; 

        @i @Term.node@ = @Expr.node@;
        @i @Term.immediate@ = @Expr.immediate@;
    @} 

    | T_NUM 
    @{
        @i @Term.node@ = new_number_leaf(@T_NUM.val@);
        @i @Term.immediate@ = 1;
    @}

    | T_ID                               /* Variablenverwendung */  
    @{ 
        @i @Term.immediate@ = 0;
        @i @Term.node@ = new_named_leaf_value(OP_ID, @T_ID.name@, (table_lookup(@Term.vars@, @T_ID.name@)==NULL) ? 0 : table_lookup(@Term.vars@, @T_ID.name@)->stack_offset, (table_lookup(@Term.vars@, @T_ID.name@)==NULL) ? 0 : table_lookup(@Term.vars@, @T_ID.name@)->param_index);

        @check check_variable_exists(@Term.vars@, @T_ID.name@); 

        @count record_var_usage(@T_ID.name@);
    @}

    | T_ID '(' Args ')'                  /* Funktionsaufruf */  
    @{ 
        @i @Term.immediate@ = 0;
        @i @Term.node@ = new_node(OP_Call, new_named_leaf(OP_ID, @T_ID.name@), @Args.node@);

        @i @Args.vars@ = @Term.vars@; 
    @} 

    | T_ID '(' Args ',' ')' 
    @{ 
        @i @Term.immediate@ = 0;
        @i @Term.node@ = new_node(OP_Call, new_named_leaf(OP_ID, @T_ID.name@), @Args.node@);

        @i @Args.vars@ = @Term.vars@; 
    @} 

    | T_ID '(' ')' 
    @{
        @i @Term.immediate@ = 0;
        @i @Term.node@ = new_node(OP_Call, new_named_leaf(OP_ID, @T_ID.name@), NULL);
    @}
    ;

Args: Expr
    @{ 
        @i @Expr.vars@ = @Args.vars@; 

        @i @Args.node@ = NULL;
        @i @Args.immediate@ = @Expr.immediate@;
    @} 
    | Args ',' Expr 
    @{
        @i @Expr.vars@ = @Args.0.vars@;
        @i @Args.1.vars@ = @Args.0.vars@;

        @i @Args.0.node@ = new_node(OP_Args, @Args.1.node@, @Expr.node@);
        @i @Args.0.immediate@ = @Args.1.immediate@ && @Expr.immediate@;
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
