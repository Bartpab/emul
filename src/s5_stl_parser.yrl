Nonterminals
    root   
    blocks
    block
    instructions
    instruction
    address
.

Terminals
    data_type
    operation
    int
    point
    be
    btype
    dp
.

Rootsymbol 
    root
.

root -> blocks : '$1'.

blocks -> block : ['$1'].
blocks -> block blocks : lists:append([['$1'], '$2']).

block -> data_type int dp instructions be : {
    extract_token(uw_atom('$1')), 
    extract_token(uw_int('$2')), 
    lists:append(['$4', [{list_to_atom("BE"), no_operand, []}]])
}.

instructions -> instruction : ['$1'].
instructions -> instruction instructions : lists:append([['$1'], '$2']).

address -> int : [extract_token(uw_int('$1'))].
address -> int point int  : [extract_token(uw_int('$3')), extract_token(uw_int('$1'))].

instruction -> operation data_type address : {
    extract_token(uw_atom('$1')), 
    extract_token(uw_atom('$2')), 
    '$3'
}.

instruction -> operation : {extract_token(uw_atom('$1')), no_operand, []}.

Erlang code.

extract_token({Token, _Line, Value}) -> Value.

uw_int({int, Line, Value}) -> {int, Line, list_to_integer(Value)}.
uw_atom({Type, Line, Value}) ->{Type, Line, list_to_atom(Value)}.
