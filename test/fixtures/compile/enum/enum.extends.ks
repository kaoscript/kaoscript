extern console: {
	log(...args)
}

enum Color {
	Red
	Green
	Blue
}

console.log(Color::Red)

enum Color {
	DarkRed = 3
	DarkGreen
	DarkBlue
}

console.log(Color::DarkGreen)