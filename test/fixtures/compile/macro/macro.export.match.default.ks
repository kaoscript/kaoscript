export macro match_tokens(i: Identifier) => 'got an identifier'
export macro match_tokens(...others) => 'got something else'

extern console

console.log(match_tokens(a))

console.log(match_tokens(42))