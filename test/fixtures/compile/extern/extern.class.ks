extern console: {
	log(...args)
}

#[rules(non-exhaustive)]
extern class Shape {
	Shape(color: string)

	draw(shape, canvas): string
}

var dyn shape = Shape.new('yellow')
console.log(shape.draw())