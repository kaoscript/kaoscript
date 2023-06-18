import './implement.class.imth.identical.gss.ks'

extern console: {
	log(...args)
}

impl Shape {
	private _name: string = 'circle'

	name() => @name
	name(@name) => this

	draw(): string {
		return `I'm drawing a \(@color) \(@name).`
	}
}

var dyn shape = Shape.makeBlue()

console.log(shape.draw())