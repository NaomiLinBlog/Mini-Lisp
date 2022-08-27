%{
#include "y.tab.h"
#include<iostream>
#include <stdio.h>
%}
separator   [ \t\n\r]
letter      [a-z]
digit       [0-9]
number      0|[1-9]{digit}*|"-"[1-9]{digit}*
ID          {letter}({letter}|{digit}|"-")*
bool_val    "#t"|"#f" 
%%
{separator}	            {}
{number}	            { yylval.intval = atoi(yytext); return(NUM); }
{bool_val}              {
                          if(strcmp(yytext,"#t")==0)
				            yylval.boolval=1;
			              else
				            yylval.boolval=0;
			              return BOOL;}

"print-num"             { return PRINT_NUM; }
"print-bool"            { return PRINT_BOOL; }
"define"                { return DEFINE; }
"if"	                { return IF;}
"+"	                    { return yytext[0]; }
"-"	                    { return yytext[0]; }
"*"	                    { return yytext[0]; }
"/"	                    { return yytext[0]; }
"("	                    { return yytext[0]; }
")"	                    { return yytext[0]; }
">"                     { return yytext[0]; }
"<"                     { return yytext[0]; }
"="                     { return yytext[0]; }
"mod"                   { return MOD; }
"and"	                { return AND; }
"or"	                { return OR; }
"not"	                { return NOT; }
"lambda"                   { return LAMBDA; }
{ID}	                { yylval.strval=strdup(yytext); return ID; }

.	                    {}
%%

