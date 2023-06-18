import './implement.throws.gss.ks'

impl Shape {
	draw(canvas): String ~ Error {
		return `I'm drawing a \(this.color()) rectangle.`
	}
}

export Shape