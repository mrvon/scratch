/* simplest version of calculator */
%{
#include <stdio.h>
%}

/* declare tokens */
%token NUMBER
%token ADD SUB MUL DIV ABS
%token OP CP /* open and close parentheses */
%token EOL   /* end of line */

%%

calclist: /* nothing */
        | calclist exp EOL { printf("=%d(0x%x)\n", $2, $2); }
        ;

exp: factor
   | exp ADD factor { $$ = $1 + $3; }
   | exp SUB factor { $$ = $1 - $3; }
   ;

factor: term
      | factor MUL term { $$ = $1 * $3; }
      | factor DIV term { $$ = $1 / $3; }
      ;

term: NUMBER
    | ABS term { $$ = $2 >= 0 ? $2 : -$2; }
    | OP exp CP { $$ = $2; }
    ;

%%

int main(void) {
    yyparse();
    return 0;
}

int yyerror(char* s) {
    fprintf(stderr, "error: %s\n", s);
    return 0;
}
