extern console

abstract class Shape {
	abstract draw(color: String): String
}

class Rectangle extends Shape {
	draw(color: String) => `I'm drawing a \(color) rectangle.`
}

var dyn r = new Rectangle()

console.log(r.draw('black'))