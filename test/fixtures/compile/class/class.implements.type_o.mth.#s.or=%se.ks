type TypeA = {
	foobar(): String
}

class ClassA implements TypeA {
	override foobar() {
		return ''
	}
}

var x = ClassA.new()

echo(`\(x.foobar())`)

export ClassA, TypeA