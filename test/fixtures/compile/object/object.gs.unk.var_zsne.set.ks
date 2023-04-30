extern console

type Color = {
	color: String?
}

var o: Color = {}

o.color = 'red'

console.log(`\(o.color)`)