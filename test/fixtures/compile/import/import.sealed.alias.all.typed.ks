import '../export/export.sealed.class.default.ks' {
	class Shape
} => T, { Shape }

var shape = Shape.new('yellow')

T.console.log(shape.draw('rectangle'))

var shapeT = T.Shape.new('yellow')

T.console.log(shapeT.draw('rectangle'))