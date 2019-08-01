extern console

#[rules(non-exhaustive)]
extern func foobar(): String

console.log(foobar())

export foobar