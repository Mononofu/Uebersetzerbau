#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include "symbols.h"

symbol_t *clone_table(symbol_t *table) {
  symbol_t *element;
  symbol_t *new_tablex;

  element=table;
  new_tablex= NULL;
  while((symbol_t *)NULL!=element) {
    /* check return value */
    new_tablex=table_add_symbol(new_tablex,element->identifier,element->type,0);
    element=element->next;
  }

  return new_tablex;
}

symbol_t *table_add_symbol(symbol_t *table, char *identifier, short type, short check) {
  symbol_t *element;
  symbol_t *new_element;

  if(table_lookup(table,identifier)!=(symbol_t *)NULL) {
    if(check) {
      fprintf(stderr,"Duplicate field %s.\n",identifier);
      exit(3);
    }

    table=table_remove_symbol(table,identifier);
  }
  
  new_element=(symbol_t *)malloc(sizeof(symbol_t));
  new_element->next=(symbol_t *)NULL;
  new_element->identifier=strdup(identifier);
  new_element->type=type;

  if((symbol_t *)NULL==table) {
    return new_element;
  }
  element=table;

  while((symbol_t *)NULL!=element->next) {
    element=element->next;
  }

  element->next=new_element;
  
  return table;
}


struct symbol_t *table_add_param(struct symbol_t *table, char *identifier, int param_index) {
  struct symbol_t *element;
  struct symbol_t *new_element;

#ifdef DEBUG
  if(param_index < 1)
    printf("param index < 1: %d\n", param_index);
#endif
  
  if(table_lookup(table,identifier)!=(struct symbol_t *)NULL) {
    fprintf(stderr,"Duplicate parameter %s.\n",identifier);
    exit(3);
  }
  
  new_element=(struct symbol_t *)malloc(sizeof(struct symbol_t));
  new_element->next=(struct symbol_t *)NULL;
  new_element->identifier=strdup(identifier);
  new_element->type=SYMBOL_TYPE_PARAM;
  new_element->param_index=param_index;

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


symbol_t *table_lookup(symbol_t *table, char *identifier) {
  symbol_t *element;

  element=table;

  if((symbol_t *)NULL==table) {
    return (symbol_t *)NULL;
  }
  
  if(strcmp(element->identifier,identifier)==0) {
    return element;
  }
  
  while((symbol_t *)NULL!=element->next) {
    element=element->next;
    if(strcmp(element->identifier,identifier)==0) {
      return element;
    }
  }

  return (symbol_t *)NULL;
}

symbol_t *table_merge(symbol_t *table, symbol_t *to_add, short check) {
  symbol_t *element;
  symbol_t *new_table=clone_table(table);
  
  element=to_add;
  while(element!=(symbol_t *)NULL) {
    new_table=table_add_symbol(new_table,element->identifier,element->type,check);
    element=element->next;
  }

  return new_table;
}

symbol_t *table_remove_symbol(symbol_t *table, char *identifier) {
  symbol_t *element;
  symbol_t *previous_element;
  symbol_t *new_element;

  if((symbol_t *)NULL==table) {
    return table;
  }

  previous_element=(symbol_t *)NULL;
  element=table;

  while((symbol_t *)NULL!=element) {
    if(strcmp(element->identifier,identifier)==0) {
      if((symbol_t *)NULL==previous_element) {
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

void check_sym(symbol_t *table, char *id, short type, short ignore_unknown) {
  symbol_t *element=table_lookup(table,id);

  if(element!=(symbol_t *)NULL) {
    if(element->type != type) {
      fprintf(stderr,"Identifier %s not a variable.\n",id);
      exit(3);
    }
  }
  else {
    if(!ignore_unknown) {
      fprintf(stderr,"Unknown identifier %s.\n",id);
      exit(3);
    }
  }
}

void check_variable_exists(symbol_t *table, char *id) {
  symbol_t *element=table_lookup(table, id);

  if(element!=(symbol_t *)NULL) {
    if(element->type != SYMBOL_TYPE_VAR && element->type != SYMBOL_TYPE_PARAM) {
      fprintf(stderr,"Identifier %s not a variable.\n",id);
      exit(3);
    }
  }
  else {
    fprintf(stderr,"Unknown identifier %s.\n",id);
    exit(3);
  }
}

void check_not_label(symbol_t *table, char *id) {
  symbol_t *element=table_lookup(table, id);

  if(element!=(symbol_t *)NULL) {
    if(element->type == SYMBOL_TYPE_LABEL) {
      fprintf(stderr,"Identifier %s not a variable.\n",id);
      exit(3);
    }
  }
}

void check_not_variable(symbol_t *table, char *id) {
  check_sym(table, id, SYMBOL_TYPE_LABEL, 1);
}

void check_label_exists(symbol_t *table, char *id) {
  check_sym(table, id, SYMBOL_TYPE_LABEL, 0);
}
