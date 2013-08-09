%{
_ = require('underscore');
var l,
  __slice = [].slice;

l = function() {
  var a, n;
  n = arguments[0], a = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
  return console.log.apply(console, [
    require('util').inspect(
    [n + ': '].concat(
        __slice.call(a)
    ), false, 10)]);
};

%}

%lex

%%
\n              return 'NEWLINE'
\s+             {}
[a-z_\-]+       return 'NAME'
[0-9]+          return 'INT'
\"(\\.|[^"])*\" return 'STRING'
\'(\\.|[^'])*\' return 'STRING'
\/.*?\/         return 'REGEX'
[!=<>]+         return 'OPERATOR'
"||"            return 'OR'
"."             return '.'
"["             return '['
"]"             return ']'
"("             return '('
")"             return ')'
","             return ','
"="             return '='
<<EOF>>         return 'EOF'
.               return 'INVALID'

/lex

%left OPERATOR

%%

QUERY
    : SELECT EOF
        {l('QUERY', $1); return $1;}
    | SELECT NEWLINE
        {l('QUERY', $1); return $1;}
    ;

COMMA
    : ','
    | OR
    ;

CONDITION
    : NAME OPERATOR NAME
        {$$ = [$1, $2, $3]; l('NAME OPERATOR NAME', $$);}
    | NAME OPERATOR STRING
        %{$$ = [$1, $2, $3];
        //{left: $1, op: $2, right: $3};
        l('NAME OPERATOR STRING', $$);
        %}
    | NAME OPERATOR INT
        %{$$ = [$1, $2, $3];
        //{left: $1, op: $2, right: $3};
        l('NAME OPERATOR INT', $$);
        %}
    | INT OPERATOR NAME OPERATOR INT
        %{$$ = [$1, $2, $3, $4, $5];
        //{left: $1, op1: $2, middle: $3, op2: $4, right: $3};
        l('INT OPERATOR NAME OPERATOR INT', $$);
        %}
    | NAME OPERATOR FLOAT
        %{$$ = [$1, $2, $3];
        //{left: $1, op: $2, right: $3};
        l('NAME OPERATOR FLOAT', $$);
        %}
    | FLOAT OPERATOR NAME OPERATOR FLOAT
        %{$$ = [$1, $2, $3, $4, $5];
        //{left: $1, op1: $2, middle: $3, op2: $4, right: $3};
        l('FLOAT OPERATOR NAME OPERATOR FLOAT', $$);
        %}
    | NESTED_CONDITIONS
        %{
        $$ = [[$1]];
        l('NESTED_CONDITIONS', $$);
        %}
    | NAME
        {$$ = $1; l('NAME', $$);}
    ;

FLOAT
    : INT '.' INT
        {return [$1, $2];}
    ;

INDEX
    : '[' SPLAT ']'
        {$$ = $2;}
    ;

SPLAT
    : NUMBER
        {$$ = $1;}
    | INT '.' '.' INT
        {$$ = [$1, $4];}
    ;

COLLECTION
    : COLLECTION OPERATOR NAME
        {$$ = [$1, $2, $3]; l('COLLECTION OPERATOR NAME', $$);}
    | COLLECTION OPERATOR NESTED_CONDITIONS OPERATOR NAME
        {$$ = [$1, $2, $3, $4, $5]; l('COLLECTION OPERATOR NESTED_CONDITIONS OPERATOR NAME', $$);}
    | NAME OPERATOR NAME
        {$$ = [$1, $2, $3]; l('NAME OPERATOR NAME', $$);}
    | NAME OPERATOR NESTED_CONDITIONS OPERATOR NAME
        {$$ = [$1, $2, $3, $4, $5]; l('NAME OPERATOR NESTED_CONDITIONS OPERATOR NAME', $$)}
    | NAME
        {$$ = $1}
    ;

SELECT
    : COLLECTION NESTED_CONDITIONS
        {$$ = [$1, $2]; l('SELECT', $1, $2);}
    | SELECT INDEX
        {$1.push($2); $$ = $1; l('SELECT INDEX', $1, $2);}
    | SELECT INDEX NESTED_CONDITIONS
        {$1.push($2); $1.push($3); $$ = $1; l('SELECT INDEX ORDER', $1, $2, $3);}
    ;

NESTED_CONDITIONS
    : '(' CONDITIONS ')'
        {$$ = $2; l('NESTED CONDITIONS /W CLOSING', $$);}
    ;

CONDITIONS
    : CONDITION
        {$$ = $1; l('CONDITION', $$);}
    | CONDITION COMMA CONDITIONS
        %{
        l('CONDITION COMMA CONDITIONS 1', $1, $2, $3);
        if(typeof $1 == "object"){
            if(typeof $3[0] != "object")
                $3 = [$3]
            if(typeof $1 == "object")
                $1 = _.flatten($1, 1)
            $3.unshift($1);
            $$ = [$2, $3];
        }else if(typeof $3 != "object"){
            $3 = [$3]
            $3.unshift($1);
            $$ = $3;
        }
        l('CONDITION COMMA CONDITIONS', $$, $1, $2, $3);
        %}
    ;