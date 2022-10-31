import '../export/export.sealed.class.default.ks' {
	class Shape
} => T, { Shape }

var shape = new Shape('yellow')

T.console.log(shape.draw('rectangle'))

var shapeT = new T.Shape('yellow')

T.console.log(shapeT.draw('rectangle'))