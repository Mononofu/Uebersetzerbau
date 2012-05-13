#ifndef SYMBOLS_H
#define SYMBOLS_H

#define SYMBOL_TYPE_LABEL 1
#define SYMBOL_TYPE_VAR 2

struct symbol_t {
  char *identifier;
  struct symbol_t *next;
  short type;
  int stack_offset;
  int param_index; /* -1 if not a parameter */
};

typedef struct symbol_t symbol_t;


symbol_t *clone_table(symbol_t *table);
symbol_t *new_table(void);
symbol_t *table_add_symbol(symbol_t *table, char *identifier, short type, short check);
symbol_t *table_lookup(symbol_t *table, char *identifier);
symbol_t *table_remove_symbol(symbol_t *table, char *identifier);
symbol_t *table_merge(symbol_t *table, symbol_t *to_add, short check);
void check_variable(symbol_t *table, char *identifier);
void check_label(symbol_t *table, char *identifier);

#endif

