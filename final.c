#include <stdio.h>
#include "lexer.h"
#include "parser.h"
#include "struct_def.h"

#include "stdbool.h"
#include <string.h>

#define DEC_MAX 350


struct ASTNode *parse_tree;
bool ParsedTreePrinted = 0;
int CurrentLine;

char **SymbolTable;
char **SymbolType;
int *SymbolValue_int;
float *SymbolValue_float;
int CurrentSymbols;

char **functionTable;
char ***functionARGS;
ASTNode **functionsExpNode;
int CurrentFunctions;

char *INT_NAME = "int";
char *REAL_NAME = "real";

//int *SymbolReg;
//int *RegState;

FILE *ASMOutFile;

void RMComment();

int main ()
{
	//Initial Parts
	SymbolTable = calloc(DEC_MAX,sizeof(char*));
	SymbolType = calloc(DEC_MAX,sizeof(char*));
	SymbolValue_int = calloc(DEC_MAX,sizeof(int));
	SymbolValue_float = calloc(DEC_MAX,sizeof(float));
	CurrentSymbols = 0;
	
	functionTable = calloc(DEC_MAX,sizeof(char*));
	functionARGS = calloc(DEC_MAX,sizeof(char**));
	functionsExpNode = calloc(DEC_MAX,sizeof(ASTNode*));
	CurrentFunctions = 0;
	
	//SymbolReg = calloc(DEC_MAX,sizeof(int));
	//RegState = calloc(DEC_MAX,sizeof(int));
	
	parse_tree = calloc(1,sizeof(ASTNode));
	parse_tree->ChildAmount = 0;
	parse_tree->childs = calloc(DEC_MAX,sizeof(ASTNode*));
	parse_tree->symbol = "RootNode";
	parse_tree->value_int = 0;
	parse_tree->value_float = 0;

	CurrentLine = 0;
	
	RMComment();
	
	printf("start parse\n");
	
	ASMOutFile = fopen("test.s","w");
	
	yyin = fopen ("test.c", "r");
	while(yyparse()!=-1);
	
	fclose(ASMOutFile);
	
	return 0;
}

void RMComment() {
	FILE *InFile = fopen("raw.c","r");
	FILE *OutFile = fopen("test.c","w");
	
	int single_comment = 0;
	int mutilpe_comment = 0;
	int need_to_write = 1;
	
	char ch1,ch2,ch3;
	
	ch1 = fgetc(InFile);
	ch2 = fgetc(InFile);
	ch3 = fgetc(InFile);
	
	if(ch1 == '/' && ch2 == '/')
	{
		need_to_write = 0;
		single_comment = 1;
	}
	else if(ch1 == '/' && ch2 == '*')
	{
		need_to_write = 0;
		mutilpe_comment = 1;
	}
	else if(ch2 == '/' && ch3 == '/')
	{
		need_to_write = 0;
		single_comment = 1;
		//printf("%c",ch1);
		//if(ch1!='\n' && ch1!='\t'){fprintf(OutFile,"%c",ch1);}
		fprintf(OutFile,"%c",ch1);
	}
	else if(ch2 == '/' && ch3 == '*')
	{
		need_to_write = 0;
		mutilpe_comment = 1;
		//printf("%c",ch1);
		//if(ch1!='\n' && ch1!='\t'){fprintf(OutFile,"%c",ch1);}
		fprintf(OutFile,"%c",ch1);
	}
	
	while (1)
	{
		if(need_to_write == 1)
		{
			//printf("%c",ch1);
			//if(ch1!='\n' && ch1!='\t'){fprintf(OutFile,"%c",ch1);}
			fprintf(OutFile,"%c",ch1);
		}
		if(single_comment == 1 && ch1 == '\n')
		{
			single_comment = 0;
			need_to_write = 1;
		}
		if(mutilpe_comment == 1 && ch2 == '*' && ch3 == '/')
		{
			mutilpe_comment = 0;
			need_to_write = 1;
			ch1 = fgetc(InFile);
			ch2 = fgetc(InFile);
			ch3 = fgetc(InFile);
			if(ch1 == '/' && ch2 == '/')
			{
				need_to_write = 0;
				single_comment = 1;
			}
			else if(ch1 == '/' && ch2 == '*')
			{
				need_to_write = 0;
				mutilpe_comment = 1;
			}
			else if(ch2 == '/' && ch3 == '/')
			{
				need_to_write = 0;
				single_comment = 1;
				//printf("%c",ch1);
				//if(ch1!='\n' && ch1!='\t'){fprintf(OutFile,"%c",ch1);}
				fprintf(OutFile,"%c",ch1);
			}
			else if(ch2 == '/' && ch3 == '*')
			{
				need_to_write = 0;
				mutilpe_comment = 1;
				//printf("%c",ch1);
				//if(ch1!='\n' && ch1!='\t'){fprintf(OutFile,"%c",ch1);}
				fprintf(OutFile,"%c",ch1);
			}
		}
		if(ch2 == '/' && ch3 == '/')
		{
			single_comment = 1;
			need_to_write = 0;
		}
		if(ch2 == '/' && ch3 == '*')
		{
			mutilpe_comment = 1;
			need_to_write = 0;
		}
		
		ch1 = ch2;
		ch2 = ch3;
		ch3 = fgetc(InFile);
		if(ch1 == EOF)
		{
			break;
		}
	}
	
	fclose(InFile);
	fclose(OutFile);
}

/*
*
*	Functions for AST Node Functions
*
*/
struct ASTNode* NewNode(char *symbol,int value,char *type,char *child_type)
{
	struct ASTNode *TmpNode = calloc(1,sizeof(*TmpNode));
	TmpNode->symbol = symbol;
	TmpNode->value_int = (int)value;
	TmpNode->value_float = (float)value;
	TmpNode->type = type;
	TmpNode->child_type = child_type;
	TmpNode->ChildAmount = 0;
	
	TmpNode->DeclareAmount = 0;
	TmpNode->DeclareList = calloc(DEC_MAX,sizeof(char*));
	
	TmpNode->code = calloc(DEC_MAX*DEC_MAX,sizeof(char*));
	TmpNode->reg = -1;

	return TmpNode;
}
void AddLine(ASTNode *StatementNode)
{
	parse_tree->childs[parse_tree->ChildAmount] = StatementNode;
	parse_tree->ChildAmount++;
}
void ShowParseTree_call(ASTNode* CurrentNode,int level)
{
	for(int j=0;j<level;j++){printf("  ");}
	printf("type:%s, child_type:%s, code %s\n",CurrentNode->type,CurrentNode->child_type,CurrentNode->code);
	if(CurrentNode->ChildAmount>0)
	{
		for(int i=0;i<CurrentNode->ChildAmount;i++)
		{
			ShowParseTree_call(CurrentNode->childs[i],level+1);
		}
	}
}
void ShowParseTree()
{
	printf("Start print total parse tree\n");
	printf("There're %d lines\n::\n",parse_tree->ChildAmount);
	if(ParsedTreePrinted == 0)
	{
		ShowParseTree_call(parse_tree,0);
		ParsedTreePrinted = 1;
	}
}

void PrintLines()
{
	printf("Current parse tree get %d lines\n",parse_tree->ChildAmount);
}


char* Concat(char *c1, char *c2, char *c3)
{
	char *tmp = calloc(DEC_MAX,sizeof(char));
	strcpy(tmp,c1);
	strcat(tmp,c2);
	strcat(tmp,c3);
	return tmp;
}

/*
*
*	Functions for symbol table
*
*/
void TestSymbol(char *symbol,char *type)
{
	printf("Get Symbols %s with type %s\n",symbol,type);
}
void DeclareSymbol(char **symbol,int amount,char *type)
{
	bool Existence = false;
	//printf("CurrentSymbols : %d\n",CurrentSymbols);
	for(int i=0;i<amount;i++)
	{
		for(int j=0;j<CurrentSymbols;j++)
		{
			if(strcmp(symbol[i],SymbolTable[j]) == 0)
			{
				Existence = true;
				SymbolValue_int[j] = 0;
				SymbolValue_float[j] = 0;
				SymbolType[j] = type;
			};
		}
		if(Existence == false)
		{
			*(SymbolTable+CurrentSymbols) = calloc(100,sizeof(char));
			*(SymbolTable+CurrentSymbols) = strdup(symbol[i]);
			SymbolValue_int[CurrentSymbols] = 0;
			SymbolValue_float[CurrentSymbols] = 0;
			SymbolType[CurrentSymbols] = type;
			
			//SymbolReg[CurrentSymbols] = CurrentSymbols+2;
			//RegState[CurrentSymbols] = 1;
			CurrentSymbols++;
		}
		Existence = false;
	}
	
	/*
	printf("Symbols :\n\n");
	for(int i=0;i<CurrentSymbols;i++)
	{
		printf("Symbol:%s, Value:%d && %f, Type:%s, reg:%d, State:%d\n",SymbolTable[i],SymbolValue_int[i],SymbolValue_float[i],SymbolType[i],SymbolReg[i],RegState[i]);
	}
	*/
}
void AssignValue(char *symbol,int value)
{
	//printf("symbol : %s,value : %d\n",symbol,(int)value);
	//printf("CurrentSymbols : %d\n",CurrentSymbols);
	for(int i=0;i<CurrentSymbols;i++)
	{
		if(strcmp(SymbolTable[i],symbol) == 0)
		{
			SymbolValue_int[i] = (int)value;
			SymbolValue_float[i] = (float)value;
		};
	}
	/*
	printf("Symbols :\n");
	for(int i=0;i<CurrentSymbols;i++)
	{
		printf("Symbol:%s, Value:%d && %f, Type:%s, reg:%d, State:%d\n",SymbolTable[i],SymbolValue_int[i],SymbolValue_float[i],SymbolType[i],SymbolReg[i],RegState[i]);
	}
	*/
	
}
int GetSymbolValue(char *symbol)
{
	for(int i=0;i<CurrentSymbols;i++)
	{
		if(strcmp(*(SymbolTable+i),symbol) == 0)
		{
			return SymbolValue_int[i];
		}
	}
	return 0;
}
void PrintSymbol(char* symbol)
{
	for(int i=0;i<CurrentSymbols;i++)
	{
		if(strcmp(SymbolTable[i],symbol) == 0)
		{
			if(strcmp(SymbolType[i],INT_NAME) == 0)
			{
				printf("%s : %d\n",SymbolTable[i],SymbolValue_int[i]);
			}
			else if(strcmp(SymbolType[i],REAL_NAME) == 0)
			{
				printf("%s : %.1f\n",SymbolTable[i],SymbolValue_float[i]);
			}
		};
	}
}
void PrintAllSymbol()
{
	printf("All containing symbols:\n");
	for(int i=0;i<CurrentSymbols;i++)
	{
		if(strcmp(SymbolType[i],INT_NAME) == 0)
		{
			printf("%s : %d\n",SymbolTable[i],SymbolValue_int[i]);
		}
		else if(strcmp(SymbolType[i],REAL_NAME) == 0)
		{
			printf("%s : %.1f\n",SymbolTable[i],SymbolValue_float[i]);
		}
	}
}

/*
*
*	Functions for function table
*
*/
void AddFunction(char* symbol, ASTNode* FunctionNode)
{
	functionTable[CurrentFunctions] = strdup(symbol);
	functionsExpNode[CurrentFunctions] = FunctionNode->childs[6];
	/*
	printf("Added function, funcitonID:%s\nfunctionExpSymbol:%s, functionValue:%d\n",
	functionTable[CurrentFunctions],functionsExpNode[CurrentFunctions]->symbol,functionsExpNode[CurrentFunctions]->value);
	printf("ARGS:%d\n",FunctionNode->args);
	*/
	FunctionNode->argList = FunctionNode->childs[3]->argList;
	functionARGS[CurrentFunctions] = FunctionNode->argList;
	/*
	for(int i=0;i<FunctionNode->args;i++)
	{
		printf("arg%d:%s\n",i,FunctionNode->argList[i]);
	}
	*/
	CurrentFunctions++;
}
void CalculateFunctionTree(ASTNode *Current,char **args_list,int *args_value,int args)
{
	if(strcmp(Current->type,"identifier") == 0)
	{
		for(int i=0;i<args;i++)
		{
			if(strcmp(Current->symbol,args_list[i]) == 0)
			{
				Current->value_int = args_value[i];
			}
		}
	}
	if(Current->ChildAmount > 0 )
	{
		for(int i=0;i<Current->ChildAmount;i++)
		{
			CalculateFunctionTree(Current->childs[i],args_list,args_value,args);
			if(Current->ChildAmount == 1)
			{
				Current->value_int = Current->childs[0]->value_int;
			}
		}
	}
	if(strcmp(Current->type,"calculate_expression") == 0)
	{
		if(strcmp(Current->childs[1]->symbol,"+") == 0)
		{
			Current->value_int = Current->childs[0]->value_int + Current->childs[2]->value_int;
		}
		if(strcmp(Current->childs[1]->symbol,"*") == 0)
		{
			Current->value_int = Current->childs[0]->value_int * Current->childs[2]->value_int;
		}
	}
	
	
}
int CallFunction(ASTNode* RootNode,char* symbol, int* argList,int args)
{
	/*
	printf("Calling function %s, with argumnets:",symbol);
	for(int i=0;i<args;i++)
	{
		printf("%d ",argList[i]);
	}
	printf(",args:%d",args);
	printf("\n");
	*/
	for(int i=0;i<CurrentFunctions;i++)
	{
		if(strcmp(symbol,functionTable[i]) == 0)
		{
			//printf("function found:%s\n",functionTable[i]);
			CalculateFunctionTree(functionsExpNode[i],functionARGS[i],argList,args);
			//ShowParseTree_call(functionsExpNode[i],5);
			RootNode->value_int = functionsExpNode[i]->value_int;
		}
	}
}

/*
*	Functions for codegen
*/
void OutputCode(char *code)
{
	fprintf(ASMOutFile,"%s",code);
}
void CreateLabel(ASTNode* parent, char *symbol)
{
	char *result = calloc(DEC_MAX*DEC_MAX,sizeof(char));
	sprintf(result,"%s:",symbol);
	printf("%s",result);
	parent->code = Concat(parent->code,result,"\n");
	free(result);
}
void DeclareVar(ASTNode*parent, int vars)
{
	char *result = calloc(DEC_MAX*DEC_MAX,sizeof(char));
	int size = -vars*4;
	//sprintf(result,"\taddi\tsp,sp,%d\n",size);
	//parent->code = Concat(parent->code,result,"\n");
}
void Operation_ASM(char *action, ASTNode* parent, ASTNode* src1, ASTNode* src2)
{
	char *result = calloc(DEC_MAX*DEC_MAX,sizeof(char));
	
	int ID1 = -1,ID2 = -1;
	
	for(int i=0;i<CurrentSymbols;i++)
	{
		if(strcmp(SymbolTable[i],src1->symbol) == 0 && src1->reg == -1)
		{
			src1->reg = i+2;
			ID1 = i;
		}
		if(strcmp(SymbolTable[i],src2->symbol) == 0 && src2->reg == -1)
		{
			src2->reg = i+2;
			ID2 = i;
		}
	}
	parent->reg = 1;
	
	if(strcmp("add",action) == 0)
	{
		sprintf(result,"\tadd\ts%d, s%d, s%d",parent->reg,src1->reg,src2->reg);
	}
	if(strcmp("sub",action) == 0)
	{
		sprintf(result,"\tsub\ts%d, s%d, s%d",parent->reg,src1->reg,src2->reg);
	}
	if(strcmp("mul",action) == 0)
	{
		sprintf(result,"\tmul\ts%d, s%d, s%d",parent->reg,src1->reg,src2->reg);
	}
	if(strcmp("div",action) == 0)
	{
		sprintf(result,"\tdiv\ts%d, s%d, s%d",parent->reg,src1->reg,src2->reg);
	}
	if(strcmp("asi",action) == 0)
	{
		if(strcmp(src2->child_type,"integer") == 0)
		{
			sprintf(result,"\tli\ts%d, %d",src1->reg,src2->value_int);
		}
		else
		{
			sprintf(result,"\tadd\ts%d, s%d, zero",src1->reg,src2->reg);
		}
	}
	
	if( strcmp(src2->code,"") != 0)
	{
		parent->code = Concat(src2->code,"\n",parent->code);
	}
	if( strcmp(src1->code,"") != 0)
	{
		parent->code = Concat(src1->code,"\n",parent->code);
	}
	parent->code = Concat(parent->code,result,"");
	free(result);
}