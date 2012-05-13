#include <stdio.h>
#include <string.h>
#include "helpers.h"

void function_header(char *name) {
  printf("\t.globl %s\n\t.type %s, @function\n%s:\n", name, name, name);
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
  if(number == 0)
    printf("trying to acces negative param reg: %d", number);
  
  char *reg_names[]={"rdi", "rsi", "rdx", "rcx", "r8", "r9"};
  return reg_names[number-1];
}

void ret(void) {
  printf("\tret\n");
}

void move(char *src, char *dst) {
  if(src == NULL || dst == NULL)
    printf("null register! src: %d, dst: %d", src, dst);

  if(strcmp(src,dst)) {
    printf("\tmovq %%%s, %%%s\n",src,dst);
  }
}
