import '../export/export.sealed.class.default.ks' {
	* => T
	
	class Shape
}

const shape = new Shape('yellow')

T.console.log(shape.draw('rectangle'))

const shapeT = new T.Shape('yellow')