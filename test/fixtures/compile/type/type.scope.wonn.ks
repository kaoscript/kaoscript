extern console

import './type.scope.source.ks' for CarFactory, Car => OldCar

var factory = new CarFactory()

console.log(`\(factory.makeCar().getType())`)
console.log(`\((new OldCar()).getType())`)