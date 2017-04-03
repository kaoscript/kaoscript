extern console

import CarFactory, Car as OldCar from ./type.scope.source.ks

const factory = new CarFactory()

console.log(`\(factory.makeCar().getType())`)
console.log(`\((new OldCar()).getType())`)