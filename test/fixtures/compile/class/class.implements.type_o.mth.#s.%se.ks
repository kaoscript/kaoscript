type TypeA = {
	foobar(): String
}

class ClassA implements TypeA {
	foobar() {
		return ''
	}
}

var x = ClassA.new()

echo(`\(x.foobar())`)