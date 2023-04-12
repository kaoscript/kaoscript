extern console

abstract class Shape {
	abstract draw(color: String): String
}

class Rectangle extends Shape {
	draw(color) => `I'm drawing a \(color) rectangle.`
}

var dyn r = Rectangle.new()

console.log(r.draw('black'))