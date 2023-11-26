const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const ANSIColor = Helper.enum(Number, 0, "BLACK", 0, "RED", 1, "GREEN", 2, "YELLOW", 3, "BLUE", 4, "MAGENTA", 5, "CYAN", 6, "WHITE", 7, "DEFAULT", 8);
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
		foobar() {
			return this.__ks_func_foobar_rt.call(null, this, this, arguments);
		}
		__ks_func_foobar_0() {
			this.__ks_func_quxbaz_0(ANSIColor.BLACK);
		}
		__ks_func_foobar_rt(that, proto, args) {
			if(args.length === 0) {
				return proto.__ks_func_foobar_0.call(that);
			}
			throw Helper.badArgs();
		}
		quxbaz() {
			return this.__ks_func_quxbaz_rt.call(null, this, this, arguments);
		}
		__ks_func_quxbaz_0(color) {
		}
		__ks_func_quxbaz_rt(that, proto, args) {
			const t0 = value => Type.isEnumInstance(value, ANSIColor);
			if(args.length === 1) {
				if(t0(args[0])) {
					return proto.__ks_func_quxbaz_0.call(that, args[0]);
				}
			}
			throw Helper.badArgs();
		}
	}
};