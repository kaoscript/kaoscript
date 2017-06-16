extern console

import './type.scope.source.ks' for CarFactory

const factory = new CarFactory()

console.log(`\(factory.makeCar().getType())`)