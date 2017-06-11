extern console

import CarFactory, Car as OldCar from './type.scope.source.ks'

class Car {
	getType() {
		return 'sedan'
	}
}

const factory = new CarFactory()

console.log(`\(factory.makeCar().getType())`)
console.log(`\((new Car()).getType())`)
console.log(`\((new OldCar()).getType())`)