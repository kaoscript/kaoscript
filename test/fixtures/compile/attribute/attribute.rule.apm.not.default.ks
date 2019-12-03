#![rules(dont-assert-parameter)]

func foobar(x: Number) {

}

foobar((() => 'foobar')())