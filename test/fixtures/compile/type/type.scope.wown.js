require("kaoscript/register");
const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	const PI = 3.14;
	var {CarFactory, Car: OldCar} = require("./.type.scope.source.ks.j5k8r9.ksb")();
	class Car {
		static __ks_new_0() {
			const o = Object.create(Car.prototype);
			o.__ks_init();
			return o;
		}
		constructor() {
			this.__ks_init();
			this.__ks_cons_rt.call(null, this, arguments);
		}
		__ks_init() {
		}
		__ks_cons_rt(that, args) {
			if(args.length !== 0) {
				throw Helper.badArgs();
			}
		}
		getType() {
			return this.__ks_func_getType_rt.call(null, this, this, arguments);
		}
		__ks_func_getType_0() {
			return "sedan";
		}
		__ks_func_getType_rt(that, proto, args) {
			if(args.length === 0) {
				return proto.__ks_func_getType_0.call(that);
			}
			throw Helper.badArgs();
		}
	}
	const factory = CarFactory.__ks_new_0();
	console.log(factory.__ks_func_makeCar_0().__ks_func_getType_0());
	console.log(Helper.toString(Car.__ks_new_0().__ks_func_getType_0()));
	console.log(OldCar.__ks_new_0().__ks_func_getType_0());
};