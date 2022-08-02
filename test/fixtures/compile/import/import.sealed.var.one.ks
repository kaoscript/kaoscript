import '../export/export.sealed.class.default.ks' for Shape

extern console: {
	log(...args)
}

var dyn shape: Shape = new Shape('yellow')
console.log(shape.draw('rectangle'))