extern console

import './type.scope.source.ks' for CarFactory, Car => OldCar

var factory = CarFactory.new()

console.log(`\(factory.makeCar().getType())`)
console.log(`\((OldCar.new()).getType())`)