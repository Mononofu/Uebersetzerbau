#ifndef SYMBOLS_H
#define SYMBOLS_H

#define SYMBOL_TYPE_FIELD 1
#define SYMBOL_TYPE_VAR 2

struct symbol_t {
  char *identifier;
  struct symbol_t *next;
  short type;
};

struct symbol_t *clone_table(struct symbol_t *table);
struct symbol_t *new_table(void);
struct symbol_t *table_add_symbol(struct symbol_t *table, char *identifier, short type, short check);
struct symbol_t *table_lookup(struct symbol_t *table, char *identifier);
struct symbol_t *table_remove_symbol(struct symbol_t *table, char *identifier);
struct symbol_t *table_merge(struct symbol_t *table, struct symbol_t *to_add, short check);
void check_variable(struct symbol_t *table, char *identifier);
void check_field(struct symbol_t *table, char *identifier);

#endif

