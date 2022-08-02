extern console

var PI = 3.14

import './type.scope.source.ks' for CarFactory, Car => OldCar

class Car {
	getType() {
		return 'sedan'
	}
}

var factory = new CarFactory()

console.log(`\(factory.makeCar().getType())`)
console.log(`\((new Car()).getType())`)
console.log(`\((new OldCar()).getType())`)