extern console

type Color = {
	color: String
}

var o: Color = {
	color: 'red'
}

o.name = 'White'

console.log(`\(o.name)`)