extern console

import './typing.scope.source.ks' for CarFactory

var factory = CarFactory.new()

console.log(`\(factory.makeCar().getType())`)