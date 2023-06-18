type TypeA = {
	foobar(): String
}

class ClassA implements TypeA {
	foobar(): String {
		return ''
	}
}

func foobar(value: TypeA) {
	echo(`\(value.foobar())`)
}

var x = ClassA.new()

foobar(x)