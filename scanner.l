/*
 * Lexer definition for simplified Python syntax.
 */

/*
 * Since we're only parsing 1 file, we don't need to have yywrap() (plus,
 * having it included messes up compilation).
 */
%option noyywrap

%option yylineno

%{
#include <iostream>
#include <stack>
#include <cstdlib>
#include "parser.hpp"

YYSTYPE yylval;


#define PUSH_TOKEN(str) do { \
  int s = yypush_parse(pstate, str, &yylval); \
  if (s != YYPUSH_MORE) {  \
    yypstate_delete(pstate); \
    return s; \
  } \
} while(0)

yypstate* pstate = yypstate_new();
bool have_error = false;
/*
 * We'll use this stack to keep track of indentation level, as described in
 * the Python docs:
 *
 * https://docs.python.org/3/reference/lexical_analysis.html#indentation
 */
std::stack<int> _indent_stack;
%}

%%

%{
  /*
   * These lines go at the top of the lexing function.  We only want to
   * initialize the indentation level stack once by pushing a 0 onto it (the
   * indentation stack should never be empty, except immediately after it is
   * created).
   */
  if (_indent_stack.empty()) {
    _indent_stack.push(0);
  }
%}

^[ \t]*\r?\n  /* Skip blank lines */

^[ \t]*#.*\r?\n  /* Skip whole-line comments. */

#.*$  /* Skip comments on the same line as a statement. */

^[ \t]+ {
  /*
   * Handle indentation as described in Python docs linked above. Note that
   * this rule's pattern treats leading spaces and leading tabs equivalently,
   * which could cause some unexpected behavior (compared to normal Python
   * indentation behavior) if they're combined in a single line.  For the
   * purposes of this project, that's OK.
   */
  if (_indent_stack.top() < yyleng) {
    /*
     * If the current indentation level is greater than the previous indentation
     * level (stored at the top of the stack), then emit an INDENT and push the
     * new indentation level onto the stack.
     */
      yylval.str = new std::string(yytext, yyleng);
      PUSH_TOKEN(INDENT);
    _indent_stack.push(yyleng);
  } else {
    /*
     * If the current indentation level is less than or equal to the previous
     * indentation level, pop indentation levels off the stack until the top is
     * equal to the current indentation level.  Emit a DEDENT for each element
     * popped from the stack.
     */
    while (!_indent_stack.empty() && _indent_stack.top() != yyleng) {
        _indent_stack.pop();
        yylval.str = new std::string(yytext, yyleng);
        PUSH_TOKEN(DEDENT);
    }

    /*
     * If we popped everything off the stack, that means the current
     * indentation level didn't match any on the stack, which is an indentation
     * error.
     */
    if (_indent_stack.empty()) {
      std::cerr << "Error: Incorrect indentation on line " << yylineno
        << std::endl;
      return 1;
    }
  }
}

^[^ \t\r\n]+ {
  /*
   * If we find a line that's not indented, pop all indentation levels off the
   * stack, and emit a DEDENT for each one.  Then, call REJECT, so the next
   * rule matching this token is also applied.
   */
  while (_indent_stack.top() != 0) {
    _indent_stack.pop();
      yylval.str = new std::string(yytext, yyleng);
      PUSH_TOKEN(DEDENT);
  }
  REJECT;
}

\r?\n {
  /*
   * This rule will apply only to endlines that come after a statement.
   * Endlines assocuated with empty lines and comments are handled above.
   * This rule handles both Unix-style and Windows-style line endings.
   */
    yylval.str = new std::string(yytext, yyleng);
    PUSH_TOKEN(NEWLINE);
}

<<EOF>> {
  /*
   * If we reach the end of the file, pop all indentation levels off the stack
   * and emit a DEDENT for each one.
   */
  while(_indent_stack.top() != 0) {
    _indent_stack.pop();
    //std::cout << "DEDENT" << std::endl;
  }
  yyterminate();
}

[ \t]  /* Ignore spaces that haven't been handled above. */

"and" {
  yylval.str = new std::string(yytext, yyleng);
  PUSH_TOKEN(AND);
}

"break" {
    yylval.str = new std::string(yytext, yyleng);
  PUSH_TOKEN(BREAK);
}

"def" {
  yylval.str = new std::string(yytext, yyleng);
  PUSH_TOKEN(DEF);
}

"elif" {
  yylval.str = new std::string(yytext, yyleng);
  PUSH_TOKEN(ELIF);
}

"else" {
  yylval.str = new std::string(yytext, yyleng);
  PUSH_TOKEN(ELSE);
}

"if" {
  yylval.str = new std::string(yytext, yyleng);
  PUSH_TOKEN(IF);
}

"not" {
  yylval.str = new std::string(yytext, yyleng);
  PUSH_TOKEN(NOT);
}

"or" {
  yylval.str = new std::string(yytext, yyleng);
  PUSH_TOKEN(OR);
}

"return" {
  yylval.str = new std::string(yytext, yyleng);
  PUSH_TOKEN(RETURN);
}

"while" {
  yylval.str = new std::string(yytext, yyleng);
  PUSH_TOKEN(WHILE);
}

"True" {
  yylval.str = new std::string(yytext, yyleng);
  PUSH_TOKEN(TRUE);
}

"False" {
  yylval.str = new std::string(yytext, yyleng);
  PUSH_TOKEN(FALSE);
}

[a-zA-Z_][a-zA-Z0-9_]* {
  /*
   * This rule handling identifiers must come after all the keyword rules above,
   * since each keyword would otherwise be treated as a valid identifier.
   */
    yylval.str = new std::string(yytext, yyleng);
    PUSH_TOKEN(IDENTIFIER); 
}

[0-9]*"."[0-9]+ {
  yylval.str = new std::string(yytext, yyleng);
  PUSH_TOKEN(FLOAT);
}

[0-9]+ {
  yylval.str = new std::string(yytext, yyleng);
  PUSH_TOKEN(NUMBER);
}

"=" {
  yylval.str = new std::string(yytext, yyleng);
  PUSH_TOKEN(ASSIGN);
}

"+" {
  yylval.str = new std::string(yytext, yyleng);
  PUSH_TOKEN(PLUS);
}

"-" {
  yylval.str = new std::string(yytext, yyleng);
  PUSH_TOKEN(MINUS);
}

"*" {
  yylval.str = new std::string(yytext, yyleng);
  PUSH_TOKEN(TIMES);
}

"/" {
  yylval.str = new std::string(yytext, yyleng);
  PUSH_TOKEN(DIVIDEDBY);
}

"==" {
  yylval.str = new std::string(yytext, yyleng);
  PUSH_TOKEN(EQ);
}

"!=" {
  yylval.str = new std::string(yytext, yyleng);
  PUSH_TOKEN(NEQ);
}

">"  {
  yylval.str = new std::string(yytext, yyleng);
  PUSH_TOKEN(GT);
}

">=" {
  yylval.str = new std::string(yytext, yyleng);
  PUSH_TOKEN(GTE);
}

"<" {
  yylval.str = new std::string(yytext, yyleng);
  PUSH_TOKEN(LT);
}

"<=" {
  yylval.str = new std::string(yytext, yyleng);
  PUSH_TOKEN(LTE);
}

"(" {
  yylval.str = new std::string(yytext, yyleng);
  PUSH_TOKEN(LPAREN);
}

")" {
  yylval.str = new std::string(yytext, yyleng);
  PUSH_TOKEN(RPAREN);
}

"," {
  yylval.str = new std::string(yytext, yyleng);
  PUSH_TOKEN(COMMA);
}

":" {
  yylval.str = new std::string(yytext, yyleng);
  PUSH_TOKEN(COLON);
}

. {
  std::cerr << "Unrecognized token on line " << yylineno << ": " << yytext
    << std::endl;
  return 1;
}

%%
