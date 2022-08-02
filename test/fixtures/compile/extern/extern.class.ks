extern console: {
	log(...args)
}

#[rules(non-exhaustive)]
extern class Shape {
	Shape(color: string)

	draw(shape, canvas): string
}

var dyn shape = new Shape('yellow')
console.log(shape.draw())