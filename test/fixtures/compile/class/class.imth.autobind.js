const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	class Foobar {
		static __ks_new_0() {
			const o = Object.create(Foobar.prototype);
			o.__ks_init();
			return o;
		}
		constructor() {
			this.__ks_init();
			this.__ks_cons_rt.call(null, this, arguments);
		}
		__ks_init() {
			this._x = 0;
		}
		__ks_cons_rt(that, args) {
			if(args.length !== 0) {
				throw Helper.badArgs();
			}
		}
		x() {
			return this.__ks_func_x_rt.call(null, this, this, arguments);
		}
		__ks_func_x_0() {
			return this._x;
		}
		__ks_func_x_rt(that, proto, args) {
			if(args.length === 0) {
				return proto.__ks_func_x_0.call(that);
			}
			throw Helper.badArgs();
		}
	}
	const f = Foobar.__ks_new_0();
	let x = Helper.bindMethod(f, "x");
	console.log(x());
	console.log(f.__ks_func_x_0());
};