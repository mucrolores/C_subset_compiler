/*******************************************************************************
 *
 * source: [parser.y]
 *
 ******************************************************************************/

%{
#include <stdio.h>
#include "lexer.h"
#include "final.h"

%}

%union {
	struct ASTNode *ANode;
}

%type <ANode> line statement statement_list function function_declaration symbol_declaration expression_as expression_ms terminal int_type decl_list comma
%type <ANode> print LP RP LBP RBP add subtraction mult division semicolon
%type <ANode> decl_type integer assign identifier

%token print
%token int_type
%token integer
%token identifier
%token add
%token subtraction
%token mult
%token division
%token assign
%token LP
%token RP
%token LBP
%token RBP
%token semicolon
%token comma

%%

line:
	function_declaration
	{
#ifdef DEBUG
		printf("\tMatch line -> function_declaration\n");
#endif
		$$ = NewNode($1->symbol,$1->value_int,"line",$1->child_type);
		$$->childs = calloc(1,sizeof($$));
		$$->childs[0] = $1;
		$$->ChildAmount = 1;
		printf("line = %s\n",$1->symbol);
		AddLine($1);
		PrintLines();
		OutputCode($1->code);
	}
|	statement_list
	{
#ifdef DEBUG
		printf("\tMatch line -> statement_list\n");
#endif
		printf("line = %s\n",$1->symbol);
		AddLine($1);
		PrintLines();
	}
|	<<EOF>>
	{
		//ShowParseTree();
		PrintAllSymbol();
		return -1;
	}
	;
	
statement:
	function semicolon
	{
#ifdef DEBUG
		printf("\tMatch statement -> function\n");
#endif
		$2 = NewNode(";",0,"semicolon","");
		$$ = NewNode(Concat($1->symbol,$2->symbol,""),$1->value_int,"statement",$1->child_type);
		$$->childs = calloc(1,sizeof($$));
		$$->childs[0] = $1;
		$$->childs[1] = $2;
		$$->ChildAmount = 2;
		$$->code = $1->code;
	}
|	symbol_declaration semicolon
	{
#ifdef DEBUG
		printf("\tMatch statement -> symbol_declaration\n");
#endif
		$2 = NewNode(";",0,"semicolon","");
		$$ = NewNode(Concat($1->symbol,$2->symbol,""),$1->value_int,"statement",$1->child_type);
		$$->childs = calloc(1,sizeof($$));
		$$->childs[0] = $1;
		$$->childs[1] = $2;
		$$->ChildAmount = 2;
		$$->code = $1->code;
	}
|	expression_as semicolon
	{
#ifdef DEBUG
		printf("\tMatch statement -> expression_as\n");
#endif
		$2 = NewNode(";",0,"semicolon","");
		$$ = NewNode(Concat($1->symbol,$2->symbol,""),$1->value_int,"statement",$1->child_type);
		$$->childs = calloc(1,sizeof($$));
		$$->childs[0] = $1;
		$$->childs[1] = $2;
		$$->ChildAmount = 2;
		$$->code = $1->code;
	}
;

statement_list:
	statement_list statement
	{
		$$ = NewNode(Concat($1->symbol,"",$2->symbol),0,"line_list",$1->child_type);
		$$->childs = calloc(2,sizeof($$));
		$$->childs[0] = $1;
		$$->childs[1] = $2;
		$$->ChildAmount = 2;
		$$->code = Concat($1->code,$2->code,"\n");
	}
|	statement
	{
		$$ = NewNode(Concat($1->symbol,"",""),0,"line_list",$1->child_type);
		$$->childs = calloc(1,sizeof($$));
		$$->childs[0] = $1;
		$$->ChildAmount = 1;
		$$->code = strdup($1->code);
	}
;

function:
	function_declaration
	{
		$$ = NewNode($1->symbol,$1->value_int,"function",$1->child_type);
		$$->childs = calloc(1,sizeof($$));
		$$->childs[0] = $1;
		$$->ChildAmount = 1;
	}
|	print LP expression_as RP
	{
#ifdef DEBUG
		printf("\tMatch function -> print LP expression_as RP\n");
#endif
		$$ = NewNode($3->symbol,$3->value_int,"function",$3->child_type);
		$1 = NewNode("print",0,"print","");
		$2 = NewNode("(",0,"LP","");
		$4 = NewNode(")",0,"RP","");
		$$->childs = calloc(4,sizeof($$));
		$$->childs[0] = $1;
		$$->childs[1] = $2;
		$$->childs[2] = $3;
		$$->childs[3] = $4;
		$$->ChildAmount = 4;
		PrintSymbol($3->symbol);
	}
;

function_declaration:
	decl_type terminal LP RP LBP RBP
	{
#ifdef DEBUG
		printf("\tMatch function_declaration -> decl_type terminal LP RP LBP RBP\n");
#endif
		$3 = NewNode("(",0,"LP","");
		$4 = NewNode(")",0,"RP","");
		$5 = NewNode("{",0,"LBP","");
		$6 = NewNode("}",0,"RBP","");
		$$ = NewNode( Concat( Concat($1->symbol, $2->symbol, $3->symbol), Concat($4->symbol, $5->symbol, $6->symbol), ""), 0, "function_declaration",$1->child_type);
		$$->childs = calloc(7,sizeof($$));
		$$->childs[0] = $1;
		$$->childs[1] = $2;
		$$->childs[2] = $3;
		$$->childs[3] = $4;
		$$->childs[4] = $5;
		$$->childs[5] = $6;
		$$->ChildAmount = 6;
		CreateLabel($$,$2->symbol);
	}
|	decl_type terminal LP RP LBP statement_list RBP
	{
#ifdef DEBUG
		printf("\tMatch function_declaration -> decl_type terminal LP line_list RP LBP RBP\n");
#endif
		$3 = NewNode("(",0,"LP","");
		$4 = NewNode(")",0,"RP","");
		$5 = NewNode("{",0,"LBP","");
		$7 = NewNode("}",0,"RBP","");
		$$ = NewNode( Concat( Concat($1->symbol, $2->symbol, $3->symbol), Concat($4->symbol, $5->symbol, $6->symbol), $7->symbol), 0, "function_declaration",$6->child_type);
		$$->childs = calloc(7,sizeof($$));
		$$->childs[0] = $1;
		$$->childs[1] = $2;
		$$->childs[2] = $3;
		$$->childs[3] = $4;
		$$->childs[4] = $5;
		$$->childs[5] = $6;
		$$->childs[6] = $7;
		$$->ChildAmount = 7;
		CreateLabel($$,$2->symbol);
		$$->code = Concat($$->code,$6->code,"");
	}
;


symbol_declaration:
	decl_type decl_list
	{
#ifdef DEBUG
		printf("\tMatch symbol_declaration -> decl_type decl_list\n");
#endif
		$$ = NewNode(Concat($1->symbol," ",$2->symbol),0,"symbol_declaration",$2->child_type);
		$$->DeclareList = $2->DeclareList;
		$$->DeclareAmount = $2->DeclareAmount;
		$$->childs = calloc(2,sizeof($$));
		$$->childs[0] = $1;
		$$->childs[1] = $2;
		$$->ChildAmount = 2;
		DeclareSymbol($2->DeclareList,$2->DeclareAmount,$1->symbol);
		//printf("delcaration : %s\n",$$->symbol);
		//printf("variables : %d\n",$$->DeclareAmount);
		$$->valueType = $1->symbol;
		$2->valueType = $1->symbol;
		DeclareVar($$,$2->DeclareAmount);
	}
;
decl_type:
	int_type
	{
#ifdef DEBUG
		printf("\tMatch decl_type -> int_type\n");
#endif
		$1 = NewNode("int",0,"int_type","");
		$$ = NewNode($1->symbol,$1->value_int,"statement",$1->child_type);
		$$->childs = calloc(1,sizeof($$));
		$$->childs[0] = $1;
		$$->ChildAmount = 1;
	}
;
decl_list:
	terminal
	{
#ifdef DEBUG
		printf("\tMatch decl_list -> terminal\n");
#endif
		$$ = NewNode($1->symbol,$1->value_int,"decl_list",$1->child_type);
		$$->DeclareList[0] = $1->symbol;
		$$->DeclareAmount = 1;
		$$->childs = calloc(1,sizeof($$));
		$$->childs[0] = $1;
		$$->ChildAmount = 1;
		$$->valueType = $1->valueType;
	}
|	decl_list comma terminal
	{
#ifdef DEBUG
		printf("\tMatch decl_list -> decl_list comma terminal\n");
#endif
		$2 = NewNode(",",0,"comma","");
		$$ = NewNode(Concat($1->symbol,$2->symbol,$3->symbol),0,"decl_list",$1->child_type);
		$$->DeclareList = $1->DeclareList;
		$$->DeclareAmount = $1->DeclareAmount + 1;
		$$->DeclareList[$1->DeclareAmount] = $3->symbol;
		$$->childs = calloc(3,sizeof($$));
		$$->childs[0] = $1;
		$$->childs[1] = $2;
		$$->childs[2] = $3;
		$$->ChildAmount = 3;
		$$->valueType = $3->valueType;
	}
;

expression_as:
	terminal assign expression_as
	{
#ifdef DEBUG
		printf("\tMatch expression_as -> terminal assign expression_as\n");
#endif
		$2 = NewNode("=",0,"assign","");
		$$ = NewNode(Concat($1->symbol,"=",$3->symbol),$3->value_int,"expression_as",$1->child_type);
		AssignValue($1->symbol,$3->value_int);
		$$->childs = calloc(3,sizeof($$));
		$$->childs[0] = $1;
		$$->childs[1] = $2;
		$$->childs[2] = $3;
		$$->ChildAmount = 3;
		Operation_ASM("asi",$$,$1,$3);
		
	}
|	expression_as add expression_ms
	{
#ifdef DEBUG
		printf("\tMatch expression_as -> expression_as add expression_as\n");
#endif
		$$ = NewNode(Concat($1->symbol,"+",$3->symbol),$1->value_int + $3->value_int,"expression_as",$1->child_type);
		$2 = NewNode("+",0,"add","");
		$$->childs = calloc(3,sizeof($$));
		$$->childs[0] = $1;
		$$->childs[1] = $2;
		$$->childs[2] = $3;
		$$->ChildAmount = 3;
		Operation_ASM("add",$$,$1,$3);
		
	}
|	expression_as subtraction expression_ms
	{
#ifdef DEBUG
		printf("\tMatch expression_as -> expression_as add expression_as\n");
#endif
		$$ = NewNode(Concat($1->symbol,"+",$3->symbol),$1->value_int - $3->value_int,"expression_as",$1->child_type);
		$2 = NewNode("-",0,"add","");
		$$->childs = calloc(3,sizeof($$));
		$$->childs[0] = $1;
		$$->childs[1] = $2;
		$$->childs[2] = $3;
		$$->ChildAmount = 3;
		Operation_ASM("sub",$$,$1,$3);
	}
|	expression_ms
	{
#ifdef DEBUG
		printf("\tMatch expression_as -> expression_ms\n");
#endif
		$$ = NewNode($1->symbol,$1->value_int,"expression_as",$1->child_type);
		$$->childs = calloc(1,sizeof($$));
		$$->childs[0] = $1;
		$$->ChildAmount = 1;
		$$->valueType = $1->valueType;
		$$->code = $1->code;
		$$->reg = $1->reg;
	}
;

expression_ms:
	expression_as mult terminal
	{
#ifdef DEBUG
		printf("\tMatch expression_ms -> expression_as mult terminal\n");
#endif
		$$ = NewNode(Concat($1->symbol,"*",$3->symbol),$1->value_int * $3->value_int,"expression_ms",$1->child_type);
		$2 = NewNode("*",0,"mul","");
		$$->childs = calloc(3,sizeof($$));
		$$->childs[0] = $1;
		$$->childs[1] = $2;
		$$->childs[2] = $3;
		$$->ChildAmount = 3;
		Operation_ASM("mul",$$,$1,$3);
	}
|	expression_as division terminal
	{
#ifdef DEBUG
		printf("\tMatch expression_ms -> expression_as mult terminal\n");
#endif
		$$ = NewNode(Concat($1->symbol,"*",$3->symbol),$1->value_int / $3->value_int,"expression_ms",$1->child_type);
		$2 = NewNode("/",0,"mult","");
		$$->childs = calloc(3,sizeof($$));
		$$->childs[0] = $1;
		$$->childs[1] = $2;
		$$->childs[2] = $3;
		$$->ChildAmount = 3;
		Operation_ASM("div",$$,$1,$3);
	}
|	terminal
	{
#ifdef DEBUG
		printf("\tMatch expression_ms -> terminal\n");
#endif
		$$ = NewNode($1->symbol,$1->value_int,"expression_ms",$1->child_type);
		$$->childs = calloc(1,sizeof($$));
		$$->childs[0] = $1;
		$$->ChildAmount = 1;
		$$->valueType = $1->valueType;
	}
;

terminal:
	integer
	{
#ifdef DEBUG
		printf("\tMatch termina -> integer\n");
#endif
		$$ = NewNode(strdup(yytext),atof(yytext),"terminal","integer");
		$1 = NewNode(strdup(yytext),atof(yytext),"integer","");
		$$->childs = calloc(1,sizeof($$));
		$$->childs[0] = $1;
		$$->ChildAmount = 1;
		$$->valueType = "int";
	}	
|	identifier
	{
#ifdef DEBUG
		printf("\tMatch terminal -> identifier\n");
#endif
		$$ = NewNode(strdup(yytext),GetSymbolValue(strdup(yytext)),"terminal","identifier");
		$1 = NewNode(strdup(yytext),0,"identifier","");
		$$->childs = calloc(1,sizeof($$));
		$$->childs[0] = $1;
		$$->ChildAmount = 1;
	}
;

%%
int yyerror (char const *s)
{
	fprintf (stderr, "%s,%d\n", s, yylineno);
}//end of function yyerror


