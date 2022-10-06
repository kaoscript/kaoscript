const {Helper, Type} = require("@kaoscript/runtime");
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
		}
		__ks_cons_rt(that, args) {
			if(args.length !== 0) {
				throw Helper.badArgs();
			}
		}
		qux() {
			return this.__ks_func_qux_rt.call(null, this, this, arguments);
		}
		__ks_func_qux_0() {
			const test = Helper.function((x, y) => {
				return x === y;
			}, (fn, ...args) => {
				const t0 = Type.isValue;
				if(args.length === 2) {
					if(t0(args[0]) && t0(args[1])) {
						return fn.call(this, args[0], args[1]);
					}
				}
				throw Helper.badArgs();
			});
		}
		__ks_func_qux_rt(that, proto, args) {
			if(args.length === 0) {
				return proto.__ks_func_qux_0.call(that);
			}
			throw Helper.badArgs();
		}
	}
};