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
		isNamed() {
			return this.__ks_func_isNamed_rt.call(null, this, this, arguments);
		}
		__ks_func_isNamed_0() {
			return false;
		}
		__ks_func_isNamed_rt(that, proto, args) {
			if(args.length === 0) {
				return proto.__ks_func_isNamed_0.call(that);
			}
			throw Helper.badArgs();
		}
	}
	class Quxbaz extends Foobar {
		static __ks_new_0() {
			const o = Object.create(Quxbaz.prototype);
			o.__ks_init();
			return o;
		}
		__ks_cons_rt(that, args) {
			super.__ks_cons_rt.call(null, that, args);
		}
		foobar() {
			return this.__ks_func_foobar_rt.call(null, this, this, arguments);
		}
		__ks_func_foobar_0(x) {
			if(!Type.isClassInstance(x, Quxbaz) || !(this.__ks_func_isNamed_0() === true) || !(x.__ks_func_isNamed_0() === true)) {
				return false;
			}
			const name = x.__ks_func_name_0();
		}
		__ks_func_foobar_rt(that, proto, args) {
			const t0 = value => Type.isClassInstance(value, Foobar);
			if(args.length === 1) {
				if(t0(args[0])) {
					return proto.__ks_func_foobar_0.call(that, args[0]);
				}
			}
			if(super.__ks_func_foobar_rt) {
				return super.__ks_func_foobar_rt.call(null, that, Foobar.prototype, args);
			}
			throw Helper.badArgs();
		}
		__ks_func_isNamed_0() {
			return true;
		}
		name() {
			return this.__ks_func_name_rt.call(null, this, this, arguments);
		}
		__ks_func_name_0() {
			return "quxbaz";
		}
		__ks_func_name_rt(that, proto, args) {
			if(args.length === 0) {
				return proto.__ks_func_name_0.call(that);
			}
			if(super.__ks_func_name_rt) {
				return super.__ks_func_name_rt.call(null, that, Foobar.prototype, args);
			}
			throw Helper.badArgs();
		}
	}
};