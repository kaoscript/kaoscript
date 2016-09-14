import Shape from ./export.final.ks

extern console: {
	log(...args)
}

let shape: Shape = new Shape('yellow')
console.log(shape.draw('rectangle'))