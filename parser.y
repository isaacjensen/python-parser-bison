%{
#include <iostream>
#include <map>
#include "parser.hpp"
#include <vector>

std::map<std::string, std::string> symbols;
std::vector<std::string*> lines;
std::string* program;

void yyerror(const char* err);
extern int yylex();

%}

%define api.push-pull push
%define api.pure full

/* %define api.value.type { std::string* } */
%union {
    std::string* str;
}

%token <str> IDENTIFIER
%token <str> AND BREAK DEF ELIF ELSE FOR IF NOT OR RETURN WHILE
%token <str> NEWLINE
%token <str> NUMBER FLOAT
%token <str> ASSIGN PLUS MINUS TIMES DIVIDEBY EQ NEQ GT GTE LT LTE
%token <str> LPAREN RPAREN COMMA COLON INDENT DEDENT TRUE FALSE

%type <str> statements statement logicals expression

// %type statement
// %type program

%left PLUS MINUS
%left TIMES DIVIDEDBY

%start statements

%%

statements
    : statements statement { $$ = new std::string(*$1 + *$2); program = $$; }
    | statement { $$ = new std::string(*$1); lines.push_back($$); }
    ;

statement
  : IDENTIFIER ASSIGN expression NEWLINE { $$ = new std::string(*$1 + *$2 + *$3 + ";" + *$4); symbols[*$1] = *$3; }
  | WHILE logicals COLON NEWLINE INDENT statements DEDENT { $$ = new std::string("while (" + *$2 + ") {" + "\n" + "\t" + *$6 + "\n" + "}"); delete $2; delete $6; }
  | IF logicals COLON NEWLINE INDENT statements DEDENT { $$ = new std::string("if (" + *$2 + ") {" + "\n" + "\t" + *$6 + "\n" + "}"); delete $2; delete $6; }
  | ELIF logicals COLON NEWLINE INDENT statements DEDENT { $$ = new std::string("else if (" + *$2 + ") {" + "\n" + "\t" + *$6 + "\n" + "}"); delete $2; delete $6; }
  | ELSE COLON NEWLINE INDENT statements DEDENT { $$ = new std::string("else { \n \t" + *$5 + "\n" + "}"); }
  ;

logicals
  : expression EQ expression { $$ = new std::string(*$1 + " == " + *$3); delete $1; delete $3; }
  | expression GT expression {  $$ = new std::string(*$1 + " > " + *$3); delete $1; delete $3; } 
  | expression GTE expression { $$ = new std::string(*$1 + " >= " + *$3); delete $1; delete $3;  }
  | expression LT expression {  $$ = new std::string(*$1 + " < " + *$3); delete $1; delete $3; }
  | expression LTE expression {  $$ = new std::string(*$1 + " <= " + *$3); delete $1; delete $3; }
  | expression NEQ expression {  $$ = new std::string(*$1 + " != " + *$3); delete $1; delete $3; }
  | expression { $$ = new std::string(*$1); }
  ;

expression
    : LPAREN expression RPAREN { $$ = new std::string("(" + *$2 + ")"); delete $2; }
    | expression PLUS expression { $$ = new std::string (*$1 + " + " + *$3); delete $1; delete $3; }
    | expression MINUS expression { $$ = new std::string (*$1 + " - " + *$3); delete $1; delete $3; }
    | expression TIMES expression { $$ = new std::string (*$1 + " * " + *$3); delete $1; delete $3; }
    | expression DIVIDEDBY expression { $$ = new std::string (*$1 + " / " + *$3); delete $1; delete $3; }
    | TRUE { $$ = new std::string("true"); }
    | FLOAT { $$ = new std::string(*$1); }
    | FALSE { $$ = new std::string("false"); }
    | BREAK NEWLINE { $$ = new std::string(*$1); }
    | NUMBER { $$ = new std::string(*$1); }
    | IDENTIFIER { $$ = new std::string(*$1); delete $1; }
    ;

%%

void yyerror(const char* err) {
    std::cerr << "Error: " << err << std::endl;
}

// int main() {
//     if (!yylex()) {
//         std::map<std::string, std::string>::iterator it;
//         for(it = symbols.begin(); it != symbols.end(); it++) {
//             std::cout << it->first << " = " << it->second << std::endl;
//         }
//         return 0;

//     } else {
//         std::cerr << "Parsing failed" << std::endl;
//         return 1;
//     }
// }
