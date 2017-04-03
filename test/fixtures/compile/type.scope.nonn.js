require("kaoscript/register");
module.exports = function() {
	var CarFactory = require("./type.scope.source.ks")().CarFactory;
	const factory = new CarFactory();
	console.log(factory.makeCar().getType());
}