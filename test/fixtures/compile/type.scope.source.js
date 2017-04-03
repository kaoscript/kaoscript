module.exports = function() {
	class CarFactory {
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
		__ks_func_makeCar_0() {
			return new Car();
		}
		makeCar() {
			if(arguments.length === 0) {
				return CarFactory.prototype.__ks_func_makeCar_0.apply(this);
			}
			throw new SyntaxError("wrong number of arguments");
		}
	}
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
			return "sport";
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
	return {
		CarFactory: CarFactory,
		Car: Car
	};
}