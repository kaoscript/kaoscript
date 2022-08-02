extern console

import './type.scope.source.ks' for CarFactory

class Car {
	getType() {
		return 'sedan'
	}
}

var factory = new CarFactory()

console.log(`\(factory.makeCar().getType())`)
console.log(`\((new Car()).getType())`)