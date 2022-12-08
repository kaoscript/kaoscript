const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const foo = t1 + ((t2 - t1) * ((2 / 3) - t3) * 6);
	const bar = h + ((1 / 3) * -(i - 1));
	class Color {
		static __ks_new_0() {
			const o = Object.create(Color.prototype);
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
		static __ks_sttc_registerSpace_0(data) {
		}
		static registerSpace() {
			const t0 = Type.isValue;
			if(arguments.length === 1) {
				if(t0(arguments[0])) {
					return Color.__ks_sttc_registerSpace_0(arguments[0]);
				}
			}
			throw Helper.badArgs();
		}
	}
	Color.__ks_sttc_registerSpace_0((() => {
		const d = new OBJ();
		d["name"] = "FBQ";
		d["formatters"] = (() => {
			const d = new OBJ();
			d.foo = Helper.function(function(t1, t2, t3) {
				return t1 + ((t2 - t1) * ((2 / 3) - t3) * 6);
			}, (fn, ...args) => {
				const t0 = Type.isNumber;
				if(args.length === 3) {
					if(t0(args[0]) && t0(args[1]) && t0(args[2])) {
						return fn.call(null, args[0], args[1], args[2]);
					}
				}
				throw Helper.badArgs();
			});
			d.bar = Helper.function(function(h, i) {
				return h + ((1 / 3) * -(i - 1));
			}, (fn, ...args) => {
				const t0 = Type.isNumber;
				if(args.length === 2) {
					if(t0(args[0]) && t0(args[1])) {
						return fn.call(null, args[0], args[1]);
					}
				}
				throw Helper.badArgs();
			});
			return d;
		})();
		return d;
	})());
	return {
		Color
	};
};