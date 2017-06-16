import './export.sealed.class.default.ks' for Shape

extern console: {
	log(...args)
}

let shape: Shape = new Shape('yellow')
console.log(shape.draw('rectangle'))