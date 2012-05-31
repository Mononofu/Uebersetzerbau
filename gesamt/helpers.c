#include <stdio.h>
#include <string.h>
#include "helpers.h"

char cur_function[100];
int cur_if = 0;
char *regs[]= {"rax", "r10", "r11", "r9", "r8", "rcx", "rdx", "rsi", "rdi"};
int reg_usage[] = {0,     0,     0,    0,    0,     0,     0,     0,     0};
char *param_regs[]={"rdi", "rsi", "rdx", "rcx", "r8", "r9"};
var_usage *vars;

void function_header(char *name, symbol_t *params, treenode* stats) {
  /* clean regs */
  int i;
  for(i = 0; i < 9; ++i)
    reg_usage[i] = 0;  

  /* init params */
  vars = NULL;
  var_usage *end;
  symbol_t *cur_parm = params;

  while(cur_parm != NULL) {
    var_usage *var = (var_usage *)malloc(sizeof(var_usage));
    var->name = strdup(cur_parm->identifier);
    var->usage_count = 0;
    if(cur_parm->param_index <= 0) {
      printf("Error - var should not be in list of parnames: %s\n", var->name);
      exit(4);
    }
    else {
      /* function args have predefined regs, so allocate them now */
      var->reg = strdup( param_regs[cur_parm->param_index - 1] );
    }

    if(vars == NULL) {
      vars = var;
      end = vars;
    } else {
      end->next = var;
      end = end->next;
    }

    cur_parm = cur_parm->next;
  } 

  /* walk tree of stats to count var usages */
  if(stats != NULL)
    count_names(stats);

  printf("\n\t.globl %s\n\t.type %s, @function\n%s:\n", name, name, name);

  /* store name of current function to prefix jump labels */
  strcpy(cur_function, name);
}

void count_names(treenode *node) {
  if(node->op == OP_ID)
    /* got a name! */
    record_var_usage(node->name);

  if(node->kids[0] != NULL)
    count_names(node->kids[0]);

  if(node->kids[1] != NULL)
    count_names(node->kids[1]);
}

char *get_8bit_reg(char* reg) {
  if(strcmp(reg, "rax") == 0) {
    return "al";
  } else if(strcmp(reg, "r10") == 0) {
    return "r10b";
  } else if(strcmp(reg, "r11") == 0) {
    return "r11b";
  } else if(strcmp(reg, "r9") == 0) {
    return "r9b";
  } else if(strcmp(reg, "r8") == 0) {
    return "r8b";
  } else if(strcmp(reg, "rcx") == 0) {
    return "cl";
  } else if(strcmp(reg, "rdx") == 0) {
    return "dl";
  } else if(strcmp(reg, "rsi") == 0) {
    return "sil";
  } else if(strcmp(reg, "rdi") == 0) {
    return "dil";
  } else {
    printf("unknown register %s", reg);
    exit(4);
  }
  return "";
}

void ret(void) {
  printf("\tret\n");
}

void imm_ret(void) {
  printf("\tmovq $0, %%rax\n\tret\n");
}

void move(char *src, char *dst) {
#ifdef DEBUG_ME
  if(src == NULL || dst == NULL) {
    printf("null register! src: %d, dst: %d\n", src, dst);
  }
#endif

  if(strcmp(src,dst)) {
    printf("\tmovq %%%s, %%%s\n",src,dst);
  } 
#ifdef DEBUG_ME 
  else {
    printf("didn't move %s to %s", src, dst);
  }
#endif

}

void start_if(treenode* node) {
  node->param_index = cur_if++;
}

void end_if(treenode* node, int immediate, int if_no) {
  if(immediate) {
    if(node->value & 1)
      printf("/* end of if */\n");
    else 
      printf("*/\n");
  } 
  else {
    printf("if_end_%d:\n", if_no);
  }
}

void print_label(char* prefix, char* name, char* postfix) {
  printf("%s%s_%s%s", prefix, cur_function, name, postfix);
}


void freereg(char *reg) {
  int i = 0;

  while( strcmp(reg, regs[i]) != 0 ) {
    ++i;
  }

  if( strcmp(reg, regs[i]) != 0) {
    printf("unknown regigster: %s\n", reg);
    exit(4);
  }

  reg_usage[i] -= 1;
}

void claimreg(char *reg) {
  int i = 0;

  while( strcmp(reg, regs[i]) != 0 ) {
    ++i;
  }

  if( strcmp(reg, regs[i]) != 0) {
    printf("unknown regigster: %s\n", reg);
    exit(4);
  }

  reg_usage[i] += 1;
}

char* newreg_with_usage_count(int count) {
  int i = 0;

  while(i < 9 && reg_usage[i] != 0) {
    ++i;
  }

  if(reg_usage[i] != 0) {
    printf("not enough registers!\n");
    exit(4);
  }

  reg_usage[i] += count;
  return regs[i];
}

char* newreg() {
  newreg_with_usage_count(1);
}

void dump_usage() {
  int i = 0;

  printf("---- Register usage ----");
  for(i = 0; i < 9; ++i) {
    printf("%s: %d\n", regs[i], reg_usage[i]);
  }
}

char* reg_for_var(char* name) {
  int i = 0;

  var_usage *cur_var = vars;
  var_usage *prev;

  while(cur_var != NULL && strcmp(cur_var->name, name) != 0) {
    prev = cur_var;
    cur_var = cur_var->next;
  }

  if(cur_var == NULL) {
    printf("var not found: %s\n", name);
    exit(4);
  } 
  else {
    if(cur_var->reg == NULL) {
      cur_var->reg = newreg_with_usage_count(cur_var->usage_count);
    }
    return cur_var->reg;
  }
}


int get_reg_usage(char *reg) {
  int i = 0;

  while( strcmp(reg, regs[i]) != 0 ) {
    ++i;
  }

  if( strcmp(reg, regs[i]) != 0) {
    printf("unknown regigster: %s\n", reg);
    exit(4);
  }

  return reg_usage[i];
}

/* called once for each time a variable is seen */
void record_var_usage(char* name) {
#ifdef DEBUG_ME
  printf("Encountered var %s\n", name);
#endif

  var_usage *cur_var = vars;
  var_usage *prev;

  while(cur_var != NULL && strcmp(cur_var->name, name) != 0) {
    prev = cur_var;
    cur_var = cur_var->next;
  }

  if(cur_var == NULL) {
    /* var is not in our list yet */
    var_usage *var = (var_usage *)malloc(sizeof(var_usage));
    var->name = strdup(name);
    var->usage_count = 1;

    if(vars == NULL) {
      vars = var;
    } else {
      prev->next = var;
    }
  }
  else {
    cur_var->usage_count += 1;
    if(cur_var->reg != NULL) {
      /* at this point, only params have registers set
       * normal vars set their reg usage at first use, 
       * for parms we need to do it now */
      claimreg(cur_var->reg);
    }
  }

}

void free_childs_alloc_reg(treenode* node) {
  /* only free if they have regs - immediates don't */
  if(node->kids[0]->reg != NULL)
    freereg(node->kids[0]->reg);
  if(node->kids[1]->reg != NULL)
    freereg(node->kids[1]->reg);
  node->reg = newreg();
}

void init_reg_usage() {
  var_usage *cur_var = vars;
  int i;

  while(cur_var != NULL) {
    i = 0;

    if(cur_var->reg == NULL) {
      printf("error: var has no register - %s\n", cur_var->name);
      exit(4);
    }
    while( strcmp(cur_var->reg, regs[i]) != 0 ) {
      ++i;
    }

    reg_usage[i] = cur_var->usage_count;
    cur_var = cur_var->next;
  }
}


/* function call helpers */
void save_regs() {
  int i;
  printf("/* save registers */\n");
  for(i = 0; i < 9; ++i) {
    if(reg_usage[i] != 0) {
      printf("\tpush %%%s\n", regs[i]);
    }  
  }
}

void set_params(treenode* node) {
  printf("/* set params */\n");
  treenode* cur = node;
  treenode* expr;
  int num_params = 1;

  /* count params */
  while(cur->op == OP_Args) {
    num_params += 1;
    cur = cur->kids[0];
  }

  cur = node;

  while(cur->op == OP_Args) {
    expr = cur->kids[1];
    /* use values from stack to set param regs */
    printf("\tmovq -%d(%%rbp), %%%s\n", 8*num_params, expr->reg, param_regs[--num_params]);

    cur = cur->kids[0];
  }

  printf("\tmovq %%%s, %%%s\n", cur->reg, param_regs[--num_params]);

}

void call_func(char* name) {
  printf("/* call %s */\n", name);
  printf("\tcall %s\n", name);
}

void restore_regs() {
  int i;
  printf("/* restore registers */\n");
  for(i = 8; i >= 0; --i) {
    if(reg_usage[i] != 0) {
      printf("\tpop %%%s\n", regs[i]);
    }  
  }
}