#include <stdio.h>
#include <string.h>
#include "helpers.h"


void function_header(char *name) {
  printf("\n\t.globl %s\n\t.type %s, @function\n%s:\n", name, name, name);
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

char *get_param_reg(long number) {
#ifdef DEBUG_ME
  if(number == 0) {
    printf("trying to acces negative param reg: %d\n", number);
  }
#endif

  char *reg_names[]={"rdi", "rsi", "rdx", "rcx", "r8", "r9"};
  return reg_names[number-1];
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
  if(immediate) 
    printf("\tcmp $1 $%li\n\tjne if_end\n", node->value); 
  else 
    printf("\tcmp $1 %%%s\n\tjne if_end\n", node->reg);
}