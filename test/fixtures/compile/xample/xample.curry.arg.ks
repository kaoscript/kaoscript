var dyn o = {
	name: 'White'
}

func fff(this, prefix) {
	return prefix + this.name
}

var dyn f = fff^$(o, ^)

var dyn s = f('Hello ')