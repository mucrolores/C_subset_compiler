/*******************************************************************************
 *
 * source: [scanner.flex]
 *
 ******************************************************************************/

%{
#include <stdio.h>
#include "parser.h"
#include "final.h"

%}

/*
%option noyywrap nodefault yylineno
*/
space		[ |\t]
print		"print"
int_type	"int"
comma		","
integer		[0-9][0-9]*
real		[0-9]*\.?[0-9]*
identifier	[[:alpha:]_][[:alnum:]_]*
add			"+"
subtraction "-"
mult		"*"
division	"/"
assign		"="
LP			"("
RP			")"
LBP			"{"
RBP			"}"
NL			"\n"
semicolon	";"

%%

{space}			{}
{NL}			{}
{print}			{return print;}
{int_type}		{return int_type;}
{comma}			{return comma;}
{integer}		{return integer;}
{identifier}	{return identifier;}
{add}			{return add;}
{subtraction}	{return subtraction;}
{mult}			{return mult;}
{division}		{return division;}
{assign}		{return assign;}
{LP} 			{return LP;}
{RP} 			{return RP;}
{LBP}			{return LBP;}
{RBP}			{return RBP;}
{semicolon}		{return semicolon;}
<<EOF>>     	{return EOF;}
%%


