#ifndef _HELPERS_H_
#define _HELPERS_H_

#define DEBUG

void function_header(char *name);
char *get_next_reg(char *name, int skip_reg);
char *get_param_reg(long number);
void ret(void);
void move(char *src, char *dst);


#endif