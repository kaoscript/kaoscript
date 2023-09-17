extern console

var PI = 3.14

import './typing.scope.source.ks' for CarFactory, Car => OldCar

class Car {
	getType() {
		return 'sedan'
	}
}

var factory = CarFactory.new()

console.log(`\(factory.makeCar().getType())`)
console.log(`\((Car.new()).getType())`)
console.log(`\((OldCar.new()).getType())`)