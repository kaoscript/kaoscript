macro match_tokens(a) => 'any'
macro match_tokens(a: Identifier) => 'identifier'
macro match_tokens(a: Number) => 'number'

extern console

console.log(match_tokens!(a))

console.log(match_tokens!(42))

console.log(match_tokens!('foobar'))

console.log(match_tokens!(1 + 1))