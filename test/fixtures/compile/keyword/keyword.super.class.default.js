const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	class Foobar {
		static __ks_new_0() {
			const o = Object.create(Foobar.prototype);
			o.__ks_init();
			o.__ks_cons_0();
			return o;
		}
		constructor() {
			this.__ks_init();
			this.__ks_cons_rt.call(null, this, arguments);
		}
		__ks_init() {
		}
		__ks_cons_0() {
		}
		__ks_cons_rt(that, args) {
			if(args.length === 0) {
				return Foobar.prototype.__ks_cons_0.call(that);
			}
			throw Helper.badArgs();
		}
		foobar() {
			return this.__ks_func_foobar_rt.call(null, this, this, arguments);
		}
		__ks_func_foobar_0() {
		}
		__ks_func_foobar_rt(that, proto, args) {
			if(args.length === 0) {
				return proto.__ks_func_foobar_0.call(that);
			}
			throw Helper.badArgs();
		}
	}
	class Quzbaz extends Foobar {
		static __ks_new_0() {
			const o = Object.create(Quzbaz.prototype);
			o.__ks_init();
			o.__ks_cons_0();
			return o;
		}
		__ks_cons_0() {
			Foobar.prototype.__ks_cons_0.call(this);
		}
		__ks_cons_rt(that, args) {
			if(args.length === 0) {
				return Quzbaz.prototype.__ks_cons_0.call(that);
			}
			throw Helper.badArgs();
		}
		__ks_func_foobar_0() {
			super.__ks_func_foobar_0();
		}
	}
};