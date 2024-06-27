extern console

syntime func foobar(value) {
	quote console.log(#(value))
}

foobar!(1)