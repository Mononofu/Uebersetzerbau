#ifndef _HELPERS_H_
#define _HELPERS_H_

#include "tree.h"

#define DEBUG_ME 

void function_header(char *name);
char *get_next_reg(char *name, int skip_reg);
char *get_param_reg(long number);
void ret(void);
void move(char *src, char *dst);
char *get_8bit_reg(char* reg);
void if_condition(treenode* node, int immediate);

#endif