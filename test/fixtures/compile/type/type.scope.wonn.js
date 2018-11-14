require("kaoscript/register");
module.exports = function() {
	var {CarFactory, Car: OldCar} = require("./type.scope.source.ks")();
	const factory = new CarFactory();
	console.log(factory.makeCar().getType());
	console.log((new OldCar()).getType());
};