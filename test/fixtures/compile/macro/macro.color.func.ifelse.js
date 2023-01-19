const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
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
	}
	Color.addSpace((() => {
		const o = new OBJ();
		o["name"] = "FBQ";
		o["formatters"] = (() => {
			const o = new OBJ();
			o.srgb = Helper.function(function(that) {
				if(that._foo === true) {
				}
				else if(that._bar === true) {
				}
				return "";
			}, (fn, ...args) => {
				const t0 = value => Type.isClassInstance(value, Color);
				if(args.length === 1) {
					if(t0(args[0])) {
						return fn.call(null, args[0]);
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