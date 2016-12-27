import Shape from ./export.sealed.class.ks

extern console: {
	log(...args)
}

let shape: Shape = new Shape('yellow')
console.log(shape.draw('rectangle'))