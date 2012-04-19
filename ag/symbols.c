#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include "symbols.h"

struct symbol_t *new_table(void) {
  return (struct symbol_t *)NULL;
}

struct symbol_t *clone_table(struct symbol_t *table) {
  struct symbol_t *element;
  struct symbol_t *new_tablex;

  element=table;
  new_tablex=new_table();
  while((struct symbol_t *)NULL!=element) {
    /* check return value */
    new_tablex=table_add_symbol(new_tablex,element->identifier,element->type,0);
    element=element->next;
  }

  return new_tablex;
}

struct symbol_t *table_add_symbol(struct symbol_t *table, char *identifier, short type, short check) {
  struct symbol_t *element;
  struct symbol_t *new_element;

  if(table_lookup(table,identifier)!=(struct symbol_t *)NULL) {
    if(check) {
      fprintf(stderr,"Duplicate field %s.\n",identifier);
      exit(3);
    }

    table=table_remove_symbol(table,identifier);
  }
  
  new_element=(struct symbol_t *)malloc(sizeof(struct symbol_t));
  new_element->next=(struct symbol_t *)NULL;
  new_element->identifier=strdup(identifier);
  new_element->type=type;

  if((struct symbol_t *)NULL==table) {
    return new_element;
  }
  element=table;

  while((struct symbol_t *)NULL!=element->next) {
    element=element->next;
  }

  element->next=new_element;
  
  return table;
}

struct symbol_t *table_lookup(struct symbol_t *table, char *identifier) {
  struct symbol_t *element;

  element=table;

  if((struct symbol_t *)NULL==table) {
    return (struct symbol_t *)NULL;
  }
  
  if(strcmp(element->identifier,identifier)==0) {
    return element;
  }
  
  while((struct symbol_t *)NULL!=element->next) {
    element=element->next;
    if(strcmp(element->identifier,identifier)==0) {
      return element;
    }
  }

  return (struct symbol_t *)NULL;
}

struct symbol_t *table_merge(struct symbol_t *table, struct symbol_t *to_add, short check) {
  struct symbol_t *element;
  struct symbol_t *new_table=clone_table(table);
  
  element=to_add;
  while(element!=(struct symbol_t *)NULL) {
    new_table=table_add_symbol(new_table,element->identifier,element->type,check);
    element=element->next;
  }

  return new_table;
}

struct symbol_t *table_remove_symbol(struct symbol_t *table, char *identifier) {
  struct symbol_t *element;
  struct symbol_t *previous_element;
  struct symbol_t *new_element;

  if((struct symbol_t *)NULL==table) {
    return table;
  }

  previous_element=(struct symbol_t *)NULL;
  element=table;

  while((struct symbol_t *)NULL!=element) {
    if(strcmp(element->identifier,identifier)==0) {
      if((struct symbol_t *)NULL==previous_element) {
        new_element=element->next;
      }
      else {
        previous_element->next=element->next;
        new_element=table;
      }
      (void)free(element->identifier);
      (void)free(element);
      return new_element;
    }
    previous_element=element;
    element=element->next;
  }

  return table;
}

void check_variable(struct symbol_t *table, char *identifier) {
  struct symbol_t *element=table_lookup(table,identifier);
  if(element!=(struct symbol_t *)NULL) {
    if(element->type!=SYMBOL_TYPE_VAR) {
      fprintf(stderr,"Identifier %s not a variable.\n",identifier);
      exit(3);
    }
  }
  else {
    fprintf(stderr,"Unknown identifier %s.\n",identifier);
    exit(3);
  }
}

void check_field(struct symbol_t *table, char *identifier) {
  struct symbol_t *element=table_lookup(table,identifier);
  if(element!=(struct symbol_t *)NULL) {
    if(element->type!=SYMBOL_TYPE_FIELD) {
      fprintf(stderr,"Identifier %s not a variable.\n",identifier);
      exit(3);
    }
  }
  else {
    fprintf(stderr,"Unknown identifier %s.\n",identifier);
    exit(3);
  }
}

