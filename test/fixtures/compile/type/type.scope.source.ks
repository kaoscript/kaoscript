extern console

class CarFactory {
	makeCar(): Car => new Car()
}

class Car {
	getType(): String => 'sport'
}

var factory = new CarFactory()

console.log(`\(factory.makeCar().getType())`)

export CarFactory, Car