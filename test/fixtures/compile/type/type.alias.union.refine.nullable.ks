type Argument = Number | Array<Number> | Null

func foobar(argument: Argument) {
	if !?argument {
	}
	else if argument is Number {
	}
	else {
		for const arg, i in argument {
		}
	}
}