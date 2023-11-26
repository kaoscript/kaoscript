const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const Color = Helper.enum(Number, 0, "Red", 0, "Green", 1, "Blue", 2);
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
			this._colors = new OBJ();
		}
		__ks_cons_rt(that, args) {
			if(args.length !== 0) {
				throw Helper.badArgs();
			}
		}
		isRed() {
			return this.__ks_func_isRed_rt.call(null, this, this, arguments);
		}
		__ks_func_isRed_0(name) {
			return this._colors[name] === Color.Red;
		}
		__ks_func_isRed_rt(that, proto, args) {
			const t0 = Type.isValue;
			if(args.length === 1) {
				if(t0(args[0])) {
					return proto.__ks_func_isRed_0.call(that, args[0]);
				}
			}
			throw Helper.badArgs();
		}
	}
};