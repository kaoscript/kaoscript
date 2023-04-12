extern console

class CarFactory {
	makeCar(): Car => Car.new()
}

class Car {
	getType(): String => 'sport'
}

var factory = CarFactory.new()

console.log(`\(factory.makeCar().getType())`)

export CarFactory, Car