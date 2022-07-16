const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	class ClassA {
		static __ks_new_0() {
			const o = Object.create(ClassA.prototype);
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
			return this;
		}
		__ks_func_foobar_rt(that, proto, args) {
			if(args.length === 0) {
				return proto.__ks_func_foobar_0.call(that);
			}
			throw Helper.badArgs();
		}
	}
	class ClassX extends ClassA {
		static __ks_new_0() {
			const o = Object.create(ClassX.prototype);
			o.__ks_init();
			return o;
		}
		__ks_init() {
			super.__ks_init();
			this._foobar = ClassA.__ks_new_0();
		}
		__ks_cons_rt(that, args) {
			super.__ks_cons_rt.call(null, that, args);
		}
		__ks_func_foobar_0() {
			return this._foobar;
		}
		__ks_func_foobar_1(foobar) {
			this._foobar = foobar;
			return this;
		}
		__ks_func_foobar_rt(that, proto, args) {
			const t0 = value => Type.isClassInstance(value, ClassA);
			if(args.length === 0) {
				return proto.__ks_func_foobar_0.call(that);
			}
			if(args.length === 1) {
				if(t0(args[0])) {
					return proto.__ks_func_foobar_1.call(that, args[0]);
				}
			}
			return super.__ks_func_foobar_rt.call(null, that, ClassA.prototype, args);
		}
	}
	class ClassY extends ClassA {
		static __ks_new_0() {
			const o = Object.create(ClassY.prototype);
			o.__ks_init();
			return o;
		}
		__ks_init() {
			super.__ks_init();
			this._foobar = ClassA.__ks_new_0();
		}
		__ks_cons_rt(that, args) {
			super.__ks_cons_rt.call(null, that, args);
		}
		quxbaz() {
			return this.__ks_func_quxbaz_rt.call(null, this, this, arguments);
		}
		__ks_func_quxbaz_0() {
			if(Type.isClassInstance(this._foobar, ClassX)) {
				this._foobar = this._foobar.__ks_func_foobar_0();
			}
		}
		__ks_func_quxbaz_rt(that, proto, args) {
			if(args.length === 0) {
				return proto.__ks_func_quxbaz_0.call(that);
			}
			if(super.__ks_func_quxbaz_rt) {
				return super.__ks_func_quxbaz_rt.call(null, that, ClassA.prototype, args);
			}
			throw Helper.badArgs();
		}
	}
};