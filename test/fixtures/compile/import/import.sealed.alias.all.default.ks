import '../export/export.sealed.class.default.ks' {
	* => T

	Shape
}

const shape = new Shape('yellow')

T.console.log(shape.draw('rectangle'))

const shapeT = new T.Shape('yellow')

T.console.log(shapeT.draw('rectangle'))