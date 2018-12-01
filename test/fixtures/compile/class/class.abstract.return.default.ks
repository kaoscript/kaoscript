abstract class Shape {
	abstract clone(): Shape
}

class Rectangle extends Shape {
	clone() => this
}