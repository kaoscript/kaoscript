type Instance = Any ^ Primitive ^ Array

class Foobar {
}

var dyn x: Instance

x = new Foobar()
x = new Date()