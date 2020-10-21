Definitions.

INT = [0-9]+
POINT = [.]
DATA_TYPE = (I|IB|IW|ID|Q|QB|QW|QD)
OPERATION = (FOO|A|AN|O|ON|NOP_0)
BTYPE     = (OB|PB)
BE        = (BE)

Rules.
{INT}           : {token, {int, TokenLine, TokenChars}}.
{DATA_TYPE}     : {token, {data_type,  TokenLine, TokenChars}}.
{OPERATION}     : {token, {operation, TokenLine, TokenChars}}.
{POINT}         : {token, {point, TokenLine, TokenChars}}.
{BTYPE}         : {token, {btype, TokenLine, TokenChars}}.
{BE}            : {token, {be, TokenLine, TokenChars}}.
[:]              : {token, {dp, TokenLine, TokenChars}}.
[\s\t\n\r]+     : skip_token.

Erlang code.
