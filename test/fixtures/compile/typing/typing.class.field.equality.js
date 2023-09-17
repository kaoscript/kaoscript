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
		quxbaz() {
			return this.__ks_func_quxbaz_rt.call(null, this, this, arguments);
		}
		__ks_func_quxbaz_0() {
		}
		__ks_func_quxbaz_rt(that, proto, args) {
			if(args.length === 0) {
				return proto.__ks_func_quxbaz_0.call(that);
			}
			if(super.__ks_func_quxbaz_rt) {
				return super.__ks_func_quxbaz_rt.call(null, that, Foobar.prototype, args);
			}
			throw Helper.badArgs();
		}
	}
	class Corge {
		static __ks_new_0() {
			const o = Object.create(Corge.prototype);
			o.__ks_init();
			return o;
		}
		constructor() {
			this.__ks_init();
			this.__ks_cons_rt.call(null, this, arguments);
		}
		__ks_init() {
			this._foo = Foobar.__ks_new_0();
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
			if(Type.isClassInstance(this._foo, Quxbaz)) {
				this._foo.__ks_func_quxbaz_0();
			}
		}
		__ks_func_qux_rt(that, proto, args) {
			if(args.length === 0) {
				return proto.__ks_func_qux_0.call(that);
			}
			throw Helper.badArgs();
		}
	}
};