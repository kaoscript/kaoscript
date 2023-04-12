type Instance = Any ^ Primitive ^ Array

class Foobar {
}


func foobar(x: Instance) {
}

foobar(Foobar.new())

export Instance