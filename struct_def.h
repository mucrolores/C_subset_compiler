typedef struct ASTNode {
	char* type; // 0 for symbol 1 for value
	char* child_type;
	char* symbol;
	int value_int;
	float value_float; 
	char* valueType;

	int DeclareAmount;
	char **DeclareList;
	
	int args;
	char **argList;
	int *InputArgs;

	struct ASTNode** childs;
	int ChildAmount;
	
	char *code;
	int reg;
}ASTNode;
