type TypeA = {
	name: String
}

class ClassA implements TypeA {
	public {
		@name
	}
	constructor(@name)
}

var x = ClassA.new('')

echo(`\(x.name)`)