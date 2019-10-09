#![rules(no-param-assert)]

func foobar(x: Number) {

}

foobar((() => 'foobar')())