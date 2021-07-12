#include "struct_def.h"


/* 
*	Functions for AST Node
*/
struct ASTNode* NewNode(char *symbol,int value,char *type,char *child_type);

void AddLine(ASTNode *StatementNode);
void ShowParseTree_call(ASTNode* CurrentNode,int level);
void ShowParseTree();
void PrintLines();

char* Concat(char *c1, char *c2, char *c3);

/*
*	Functions for symbol table
*/
void TestSymbol(char *symbol,char *type);
void DeclareSymbol(char **symbol,int amount,char *type);
void AssignValue(char *symbol,int value);
int GetSymbolValue(char *symbol);

void PrintSymbol(char* symbol);
void PrintAllSymbol();

/*
*	Functions for codegen
*/
void OutputCode(char *code);
void CreateLabel(ASTNode* parent, char *symbol);
void DeclareVar(ASTNode*parent, int vars);
void Operation_ASM(char *action, ASTNode* parent, ASTNode* src1, ASTNode* src2);



