extern console: {
	log(...args)
}

enum Color {
	Red
	Green
	Blue
}

var dyn color = Color.Red

console.log(color)