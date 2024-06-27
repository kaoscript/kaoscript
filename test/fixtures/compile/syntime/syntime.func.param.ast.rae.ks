extern console

syntime func foobar(...args) {
	quote console.log(#(args))
}

foobar(1, 2, 3)