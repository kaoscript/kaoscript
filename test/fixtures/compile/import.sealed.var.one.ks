import Shape from ./export.sealed.class.default.ks

extern console: {
	log(...args)
}

let shape: Shape = new Shape('yellow')
console.log(shape.draw('rectangle'))