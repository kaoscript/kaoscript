#![rules(dont-assert-parameter-type)]

func foobar(x: Number) {

}

foobar((() => 'foobar')())