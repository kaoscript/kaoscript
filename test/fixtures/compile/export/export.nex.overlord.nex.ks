extern console

#[rules(non-exhaustive)]
extern func foobar(): String
extern func foobar(x: Number, y: Number): String

console.log(foobar('foobar'))

export foobar