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
	class Quxbaz {
		static __ks_new_0() {
			const o = Object.create(Quxbaz.prototype);
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
	return {
		Foobar,
		Quxbaz
	};
};