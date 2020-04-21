grammar IR ;

ID : [a-zA-Z][a-zA-Z0-9]+ ;
SIZE : [0-9]+ ;
WS : [ \r\t] + -> skip ;
RELOP : ('<'|'>'|'<='|'>='|'=='|'!=') ;
PriExp : ('&' | '*') ID;

stmtLabel       : 'LABEL' ID ;
stmtFunction    : 'FUNCTION' ID ;
stmtAssign      : ID ':=' PriExp ;
stmtAdd         : ID ':=' PriExp '+' PriExp ;
stmtSub         : ID ':=' PriExp '-' PriExp ;
stmtMul         : ID ':=' PriExp '*' PriExp ;
stmtDiv         : ID ':=' PriExp '/' PriExp ;
stmtTakeAddr    : ID ':=' '&' ID ;
stmtDeref       : ID ':=' '*' ID ;
stmtDerefAssign : '*' ID ':=' PriExp ;
stmtGoto        : 'GOTO' PriExp ;
stmtBranch      : 'IF' PriExp RELOP PriExp 'GOTO' PriExp ;
stmtReturn      : 'RETURN' PriExp ;
stmtDec         : 'DEC' PriExp SIZE ;
stmtArg         : 'ARG' PriExp ;
stmtCall        : ID ':=' 'CALL' ID ;
stmtParam       : 'PARAM' PriExp ;
stmtRead        : 'READ' ID ;
stmtWrite       : 'WRITE' PriExp ;

stmt : stmtLabel '\n'
	 | stmtFunction '\n'
	 | stmtAssign '\n'
	 | stmtAdd '\n'
	 | stmtSub '\n'
	 | stmtMul '\n'
	 | stmtDiv '\n'
	 | stmtTakeAddr '\n'
	 | stmtDeref '\n'
	 | stmtDerefAssign '\n'
	 | stmtGoto '\n'
	 | stmtBranch '\n'
	 | stmtReturn '\n'
	 | stmtDec '\n'
	 | stmtArg '\n'
	 | stmtCall '\n'
	 | stmtParam '\n'
	 | stmtRead '\n'
	 | stmtWrite '\n'
	 ;

program : stmt + ;
