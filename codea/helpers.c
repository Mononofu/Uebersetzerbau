#include <stdio.h>
#include <string.h>
#include "helpers.h"

char cur_function[100];
int cur_if = 0;
char *regs[]= {"rax", "r10", "r11", "r9", "r8", "rcx", "rdx", "rsi", "rdi"};
int reg_usage[] = {0,     0,     0,    0,    0,     0,     0,     0,     0};
char *param_regs[]={"rdi", "rsi", "rdx", "rcx", "r8", "r9"};
var_usage *vars;


void clean_slate() {
  /* clean function specific stuff */
  int i;
  for(i = 0; i < 9; ++i)
    reg_usage[i] = 0;  

  vars = NULL;
}

void function_header(char *name) {
  init_reg_usage();
  printf("\n\t.globl %s\n\t.type %s, @function\n%s:\n", name, name, name);

  /* store name of current function to prefix jump labels */
  strcpy(cur_function, name);
}

char *get_next_reg(char *name, int skip_reg) {
  char *reg_names[]={"rax", "r10", "r11", "r9", "r8", "rcx", "rdx", "rsi", "rdi"};
  int index, a;
  if(name==(char *)NULL) {
    index=0;
  }
  else {
    for(a=0;a<9;a++) {
      if(!strcmp(name,reg_names[a])) {
        index=a+1;
        break;
      }
    }
  }
  if(skip_reg) {
    index++;
  }
  return reg_names[index];
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

void if_condition(treenode* node, int immediate){
  if(immediate) {
    if(node->value & 1)
      printf("/* always true */\n");
    else
      printf("/* always false\n");
  }
  else {
    printf("\tand $1, %%%s\n\tjz if_end_%d\n", node->reg, cur_if);
  }
}

void end_if(treenode* node, int immediate) {
  if(immediate) {
    if(node->value & 1)
      printf("/* end of if */\n");
    else 
      printf("*/\n");
  } 
  else {
    printf("if_end_%d:\n", cur_if);
    cur_if++;
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

char* newreg() {
  int i = 0;

  while(i < 9 && reg_usage[i] != 0) {
    ++i;
  }

  if(reg_usage[i] != 0) {
    printf("not enough registers!\n");
    exit(4);
  }

  reg_usage[i] += 1;
  return regs[i];
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
    return cur_var->reg;
  }

    /*while(i < 9 && reg_usage[i] != 0) {
      ++i;
    }

    if(reg_usage[i] != 0) {
      printf("not enough registers!\n");
      exit(4);
    }

    var_usage *cur_var = vars;
    while(cur_var != NULL && strcmp(cur_var->name, name) != 0) {
      cur_var = cur_var->next;
    }

    reg_usage[i] += cur_var->usage_count;
    return regs[i];*/
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
  }

}

/* called once for every function parameter */
void record_param(long number, char* name) { 
  var_usage *cur_var = vars;
  var_usage *prev;

  while(cur_var != NULL) {
    prev = cur_var;
    cur_var = cur_var->next;
  }

  var_usage *var = (var_usage *)malloc(sizeof(var_usage));
  var->name = strdup(name);
  var->usage_count = 0;
  var->reg = strdup( param_regs[number-1] );

  if(vars == NULL) {
    vars = var;
  } else {
    prev->next = var;
  }
}


char *get_param_reg(long number) {
#ifdef DEBUG_ME
  if(number == 0) {
    printf("trying to acces negative param reg: %d\n", number);
  }
#endif

  char *reg_names[]={"rdi", "rsi", "rdx", "rcx", "r8", "r9"};
  return reg_names[number-1];
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