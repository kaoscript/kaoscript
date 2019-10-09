#![rules(no-param-type-assert)]

func foobar(x: Number) {

}

foobar((() => 'foobar')())