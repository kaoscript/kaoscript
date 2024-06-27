syntime func match_tokens(i: Ast(Identifier)) => 'got an identifier'
syntime func match_tokens(...others) => 'got something else'

extern console

console.log(match_tokens(a))

console.log(match_tokens(42))