syntime func match_tokens(a) => 'any'
syntime func match_tokens(a: Ast(Identifier)) => 'identifier'
syntime func match_tokens(a: Ast(NumericExpression)) => 'number'

extern console

console.log(match_tokens(a))

console.log(match_tokens(42))

console.log(match_tokens('foobar'))

console.log(match_tokens(1 + 1))