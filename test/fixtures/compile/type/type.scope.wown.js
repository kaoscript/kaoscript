require("kaoscript/register");
module.exports = function() {
	const PI = 3.14;
	var {CarFactory, Car: OldCar} = require("./type.scope.source.ks")();
	class Car {
		constructor() {
			this.__ks_init();
			this.__ks_cons(arguments);
		}
		__ks_init() {
		}
		__ks_cons(args) {
			if(args.length !== 0) {
				throw new SyntaxError("wrong number of arguments");
			}
		}
		__ks_func_getType_0() {
			return "sedan";
		}
		getType() {
			if(arguments.length === 0) {
				return Car.prototype.__ks_func_getType_0.apply(this);
			}
			throw new SyntaxError("wrong number of arguments");
		}
	}
	const factory = new CarFactory();
	console.log(factory.makeCar().getType());
	console.log("" + (new Car()).getType());
	console.log((new OldCar()).getType());
};