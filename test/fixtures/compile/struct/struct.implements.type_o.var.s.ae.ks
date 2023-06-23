type TypeA = {
	name: String
}

struct StructA implements TypeA {
	name
}

var x = StructA.new('')

echo(`\(x.name)`)