import '../export/export.sealed.class.default.ks' {
	* => T

	Shape
}

var shape = new Shape('yellow')

T.console.log(shape.draw('rectangle'))

var shapeT = new T.Shape('yellow')

T.console.log(shapeT.draw('rectangle'))