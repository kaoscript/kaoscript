const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	class Foobar {
		static __ks_new_0(...args) {
			const o = Object.create(Foobar.prototype);
			o.__ks_init();
			o.__ks_cons_0(...args);
			return o;
		}
		static __ks_new_1(...args) {
			const o = Object.create(Foobar.prototype);
			o.__ks_init();
			o.__ks_cons_1(...args);
			return o;
		}
		constructor() {
			this.__ks_init();
			this.__ks_cons_rt.call(null, this, arguments);
		}
		__ks_init() {
		}
		__ks_cons_0(x, y, z) {
			if(y === void 0 || y === null) {
				y = 0;
			}
		}
		__ks_cons_1(x, y, z) {
			if(y === void 0 || y === null) {
				y = 0;
			}
		}
		__ks_cons_rt(that, args) {
			const t0 = Type.isValue;
			const t1 = Type.isNumber;
			const t2 = Type.isString;
			if(args.length === 2) {
				if(t0(args[0])) {
					if(t1(args[1])) {
						return Foobar.prototype.__ks_cons_0.call(that, args[0], void 0, args[1]);
					}
					if(t2(args[1])) {
						return Foobar.prototype.__ks_cons_1.call(that, args[0], void 0, args[1]);
					}
					throw Helper.badArgs();
				}
				throw Helper.badArgs();
			}
			if(args.length === 3) {
				if(t0(args[0])) {
					if(t1(args[2])) {
						return Foobar.prototype.__ks_cons_0.call(that, args[0], args[1], args[2]);
					}
					if(t2(args[2])) {
						return Foobar.prototype.__ks_cons_1.call(that, args[0], args[1], args[2]);
					}
				}
			}
			throw Helper.badArgs();
		}
	}
};