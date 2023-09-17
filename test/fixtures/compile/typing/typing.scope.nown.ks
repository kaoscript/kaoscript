extern console

import './typing.scope.source.ks' for CarFactory

class Car {
	getType() {
		return 'sedan'
	}
}

var factory = CarFactory.new()

console.log(`\(factory.makeCar().getType())`)
console.log(`\((Car.new()).getType())`)