#ifndef __TREE_H_
#define __TREE_H_

#ifndef CODE
typedef struct burm_state *STATEPTR_TYPE; 
#endif

enum {
  /* logical ops */
  OP_NOT = 1,
  OP_AND,
  OP_OR,

  /* comparison */
  OP_EQ,
  OP_GT,
  OP_GEQ,
  OP_LS,
  OP_LEQ,
  OP_NEQ,

  /* arithmetic */
  OP_ADD,
  OP_MUL,
  OP_NEG,

  /* various */
  OP_ID,
  OP_Number,
  OP_Field,
  OP_Return,
  OP_Zero,
  OP_One,
  OP_Args,
  OP_Call,
  OP_ReadMem
};

static char rule_names[100][100]={
  "",
  /* logical ops */
  "OP_NOT",
  "OP_AND",
  "OP_OR",

  /* comparison */
  "OP_EQ",
  "OP_GT",
  "OP_GEQ",
  "OP_LS",
  "OP_LEQ",
  "OP_NEQ",

  /* arithmetic */
  "OP_ADD",
  "OP_MUL",
  "OP_NEG",

  /* various */
  "OP_ID",
  "OP_Number",
  "OP_Field",
  "OP_Return",
  "OP_Zero",
  "OP_One",
  "OP_Args",
  "OP_Call",
  "OP_ReadMem"
};
    

/* struct for the tree build by ox for iburg */
typedef struct treenode {
  int op;
  struct treenode *kids[2];
  STATEPTR_TYPE label;
  char *name;
  long value;
  char *reg;
  struct treenode *parent;
  int skip_reg;
  int param_index; /* -1 if not a parameter */
  int usage_count;
} treenode;

typedef treenode *treenodep;

/* macros for iburg being able to traverse the tree */
#define NODEPTR_TYPE      treenodep
#define OP_LABEL(p)       ((p)->op)
#define LEFT_CHILD(p)     ((p)->kids[0])
#define RIGHT_CHILD(p)    ((p)->kids[1])
#define STATE_LABEL(p)    ((p)->label)
#define PANIC     printf

/* see tree.c for description about these procedures */
treenode *new_node(int op, treenode *left, treenode *right);
treenode *new_node_value(int op, treenode *left, treenode *right, long value, int param);
treenode *new_leaf(int op);
treenode *new_number_leaf(long value);
treenode *new_named_leaf(int op, char *name);
treenode *new_named_leaf_value(int op, char *name, long value, int param);
treenode *new_named_node(int op, treenode *left, treenode *right, char *name);

void write_indent(int indent);
void write_tree(treenode *node, int indent);

#endif /* __TREE_H */
