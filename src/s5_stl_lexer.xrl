Definitions.

INT = [0-9]+
POINT = [.]
DATA_TYPE = (I|IB|IW|ID|Q|QB|QW|QD|OB|PB|SB|FB|T|KC)
OPERATION = (SHOW|A|A=|AN=|AN|O|O=|ON|ON=|L|T|S|R|=|SP|SE|SD|SS|SF|CU|CD|JC|JU|BEU|BEC|NOP_0)
BE        = (BE)

Rules.
{INT}           : {token, {int, TokenLine, TokenChars}}.
{DATA_TYPE}     : {token, {data_type,  TokenLine, TokenChars}}.
{OPERATION}     : {token, {operation, TokenLine, TokenChars}}.
{POINT}         : {token, {point, TokenLine, TokenChars}}.
{BTYPE}         : {token, {btype, TokenLine, TokenChars}}.
{BE}            : {token, {be, TokenLine, TokenChars}}.
[:]             : {token, {dp, TokenLine, TokenChars}}.
\%(.*?)\n              : skip_token.
[\s\t\n\r]+     : skip_token.

Erlang code.
