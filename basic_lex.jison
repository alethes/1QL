%{
_ = require('underscore');
oneQL = require('oneQL');
var l,
  __slice = [].slice;
l = oneQL.l;
l = function(){};
%}

%lex

%%
\n              return 'NEWLINE'
\s+             {}
[a-z_\-]+[a-z_\-\.]*       return 'NAME'
[0-9]+          return 'INT'
\"(\\.|[^"])*\" return 'STRING'
\'(\\.|[^'])*\' return 'STRING'
\/.*?\/         return 'REGEX'
[!=<>]+         return 'OPERATOR'
"||"            return 'OR'
"#"             return '#'
"."             return '.'
":"             return ':'
"["             return '['
"]"             return ']'
"("             return '('
")"             return ')'
","             return ','
"="             return '='
<<EOF>>         return 'EOF'
.               return 'INVALID'

/lex

%right OPERATOR, FNAME, FNAMEANDOPERATOR

%%

QUERY
    : SELECT EOF
        {l('QUERY', $1); return oneQL.load($1);}
    | SELECT NEWLINE
        {l('QUERY', $1); return oneQL.load($1);}
    ;

COMMA
    : ','
    | OR
    ;

CONDITION
    : FNAME OPERATOR FNAME
        {
            $$ = [$1, $2, $3];
            l('FNAME OPERATOR FNAME', $$);
        }
    | FNAME OPERATOR STRING
        %{
            $$ = oneQL.condition([$1, $2, $3]);
            l('FNAME OPERATOR STRING', $$);
        %}
    | FNAME OPERATOR INT
        %{
            $$ = oneQL.condition([$1, $2, $3]);
            l('FNAME OPERATOR INT', $$);
        %}
    | INT OPERATOR FNAME OPERATOR INT
        %{
            $$ = oneQL.condition([$1, $2, $3, $4, $5]);
            l('INT OPERATOR FNAME OPERATOR INT', $$);
        %}
    | FNAME OPERATOR FLOAT
        %{
            $$ = oneQL.condition([$1, $2, $3]);
            l('FNAME OPERATOR FLOAT', $$);
        %}
    | FLOAT OPERATOR FNAME OPERATOR FLOAT
        %{
            $$ = oneQL.condition([$1, $2, $3, $4, $5]);
            l('FLOAT OPERATOR FNAME OPERATOR FLOAT', $$);
        %}
    | NESTED_CONDITIONS
        %{
            $$ = [$1];
            l('NESTED_CONDITIONS', $$);
        %}
    | FNAME
        {
            $$ = $1;
            l('FNAME', $$);
        }
    ;

FNAME
    : NAME
        {$$ = $1;}
    | NAME ':' NAME
        {$$ = [$1, $3];}
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

COLLECTIONANDOPERATOR
    : COLLECTION OPERATOR
        {$$ = [$1, $2];}
    ;
FNAMEANDOPERATOR
    : FNAME OPERATOR
        {$$ = [$1, $2];}
    ;

COLLECTIONSINGLE
    : FNAME '('
        {$$ = $1}
    ;

COLLECTION
    : COLLECTIONANDOPERATOR FNAME
        {$1.push($2); $$ = oneQL.detectJoin($1); l('COLLECTION OPERATOR FNAME', $$);}
    | FNAMEANDOPERATOR NESTED_CONDITIONS OPERATOR FNAME
        {$1.push($2, $3, $4); $$ = oneQL.detectJoin($1); l('FNAME OPERATOR NESTED_CONDITIONS OPERATOR FNAME', $$)}
    | FNAMEANDOPERATOR FNAME
        {$1.push($2); $$ = oneQL.detectJoin($1); l('FNAME OPERATOR NESTED_CONDITIONS OPERATOR FNAME', $$)}
    ;

SELECT
    : COLLECTION NESTED_CONDITIONS
        {$$ = [$1, $2]; l('SELECT', $1, $2);}
    | COLLECTIONSINGLE NESTED_CONDITIONS_NO_LB
        {$$ = [$1, $2]; l('SELECT', $1, $2);}
    | SELECT INDEX
        {$1.push($2); $$ = $1; l('SELECT INDEX', $1, $2);}
    | SELECT INDEX NESTED_CONDITIONS
        {$1.push($2); $1.push($3); $$ = $1; l('SELECT INDEX ORDER', $1, $2, $3);}
    ;

NESTED_CONDITIONS
    : '(' CONDITIONS ')'
        {$$ = oneQL.getConditions($2); l('NESTED CONDITIONS /W CLOSING', $$);}
    ;
NESTED_CONDITIONS_NO_LB
    : CONDITIONS ')'
        {$$ = oneQL.getConditions($1); l('NESTED CONDITIONS /W CLOSING', $$);}
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
        }else if(typeof $3 != "object")
            $3 = [$3]
        $3.unshift($1);
        if($2 == ',')
            $$ = $3;
        else if($2 == '||')
            $$ = [$2, $3];
        l('CONDITION COMMA CONDITIONS', $$, $1, $2, $3);
        %}
    ;