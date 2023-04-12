type Instance = Any ^ Primitive ^ Array

class Foobar {
}

var mut x: Instance

x = Foobar.new()
x = Date.new()