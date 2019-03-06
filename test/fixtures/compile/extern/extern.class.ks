extern console: {
	log(...args)
}

extern class Shape {
	Shape(color: string)

	draw(shape, canvas): string
}

let shape = new Shape('yellow')
console.log(shape.draw())