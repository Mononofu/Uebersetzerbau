#ifndef _HELPERS_H_
#define _HELPERS_H_

#include "tree.h"
#include "symbols.h"

#define DEBUG_ME


struct var_usage {
  char *name;
  char *reg;
  struct var_usage *next;
  int usage_count;
};

typedef struct var_usage var_usage;

void clean_slate(); 
void init_reg_usage();

void function_header(char *name, symbol_t *params, treenode* stats);
char *get_next_reg(char *name, int skip_reg);
char *get_param_reg(long number);
void ret(void);
void move(char *src, char *dst);
char *get_8bit_reg(char* reg);
void start_if(treenode* node);
void end_if(treenode* node, int immediate, int if_no);
void print_label(char* prefix, char* name, char* postfix);

void freereg(char *reg);
void claimreg(char *reg);
char* newreg();
char* reg_for_var(char* name);
int get_reg_usage(char *reg);

void record_var_usage(char* name);
void record_param(long number, char* name);

void free_childs_alloc_reg(treenode* node);

void dump_usage();

#endif