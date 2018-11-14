let o = {
	name: 'White'
}

func fff(prefix) {
	return prefix + this.name
}

let f = fff^$(o)

let s = f('Hello ')