extern console

import './type.scope.source.ks' for CarFactory

var factory = new CarFactory()

console.log(`\(factory.makeCar().getType())`)