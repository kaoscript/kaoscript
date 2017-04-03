extern console

import CarFactory from ./type.scope.source.ks

const factory = new CarFactory()

console.log(`\(factory.makeCar().getType())`)