type TypeA = [ String ]

tuple TupleA implements TypeA [
	name
]

var x = TupleA.new('')

echo(`\(x.name)`)