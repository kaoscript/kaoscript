const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function format() {
		return format.__ks_rt(this, arguments);
	};
	format.__ks_0 = function(t1, t2, t3, h, i) {
		const foo = t1 + ((t2 - t1) * ((2 / 3) - t3) * 6);
		const bar = h + ((1 / 3) * -(i - 1));
	};
	format.__ks_rt = function(that, args) {
		const t0 = Type.isNumber;
		if(args.length === 5) {
			if(t0(args[0]) && t0(args[1]) && t0(args[2]) && t0(args[3]) && t0(args[4])) {
				return format.__ks_0.call(that, args[0], args[1], args[2], args[3], args[4]);
			}
		}
		throw Helper.badArgs();
	};
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
		static __ks_sttc_addSpace_0(data) {
		}
		static addSpace() {
			const t0 = Type.isValue;
			if(arguments.length === 1) {
				if(t0(arguments[0])) {
					return Color.__ks_sttc_addSpace_0(arguments[0]);
				}
			}
			throw Helper.badArgs();
		}
	}
	Color.__ks_sttc_addSpace_0((() => {
		const o = new OBJ();
		o["name"] = "FBQ";
		o["formatters"] = (() => {
			const o = new OBJ();
			o.foo = Helper.function(function(t1, t2, t3) {
				return t1 + ((t2 - t1) * ((2 / 3) - t3) * 6);
			}, (that, fn, ...args) => {
				const t0 = Type.isNumber;
				if(args.length === 3) {
					if(t0(args[0]) && t0(args[1]) && t0(args[2])) {
						return fn.call(null, args[0], args[1], args[2]);
					}
				}
				throw Helper.badArgs();
			});
			o.bar = Helper.function(function(h, i) {
				return h + ((1 / 3) * -(i - 1));
			}, (that, fn, ...args) => {
				const t0 = Type.isNumber;
				if(args.length === 2) {
					if(t0(args[0]) && t0(args[1])) {
						return fn.call(null, args[0], args[1]);
					}
				}
				throw Helper.badArgs();
			});
			return o;
		})();
		return o;
	})());
	return {
		Color
	};
};