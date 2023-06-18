import './implement.static.gss.ks'

extern console: {
	log(...args)
}

impl Shape {
	static makeRed(): Shape {
		return Shape.new('red')
	}
}

var dyn shape = Shape.makeRed()

console.log(shape.draw())