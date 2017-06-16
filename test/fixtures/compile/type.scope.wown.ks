extern console

import './type.scope.source.ks' for CarFactory, Car => OldCar

class Car {
	getType() {
		return 'sedan'
	}
}

const factory = new CarFactory()

console.log(`\(factory.makeCar().getType())`)
console.log(`\((new Car()).getType())`)
console.log(`\((new OldCar()).getType())`)