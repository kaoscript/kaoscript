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
		__ks_func_foobar_0(x) {
			return false;
		}
		__ks_func_foobar_rt(that, proto, args) {
			const t0 = value => Type.isClassInstance(value, ClassA);
			if(args.length === 1) {
				if(t0(args[0])) {
					return proto.__ks_func_foobar_0.call(that, args[0]);
				}
			}
			throw Helper.badArgs();
		}
	}
	class ClassB extends ClassA {
		static __ks_new_0() {
			const o = Object.create(ClassB.prototype);
			o.__ks_init();
			return o;
		}
		__ks_cons_rt(that, args) {
			super.__ks_cons_rt.call(null, that, args);
		}
		__ks_func_foobar_1(x) {
			return false;
		}
		__ks_func_foobar_2(x) {
			return false;
		}
		__ks_func_foobar_0(x) {
			if(Type.isClassInstance(x, ClassB)) {
				return this.__ks_func_foobar_1(x);
			}
			if((Type.isClassInstance(x, ClassC) || Type.isClassInstance(x, ClassD))) {
				return this.__ks_func_foobar_2(x);
			}
			return super.__ks_func_foobar_0(x);
		}
		__ks_func_foobar_rt(that, proto, args) {
			const t0 = value => Type.isClassInstance(value, ClassB);
			const t1 = value => Type.isClassInstance(value, ClassD) || Type.isClassInstance(value, ClassC);
			if(args.length === 1) {
				if(t0(args[0])) {
					return proto.__ks_func_foobar_1.call(that, args[0]);
				}
				if(t1(args[0])) {
					return proto.__ks_func_foobar_2.call(that, args[0]);
				}
			}
			return super.__ks_func_foobar_rt.call(null, that, ClassA.prototype, args);
		}
	}
	class ClassC extends ClassA {
		static __ks_new_0() {
			const o = Object.create(ClassC.prototype);
			o.__ks_init();
			return o;
		}
		__ks_cons_rt(that, args) {
			super.__ks_cons_rt.call(null, that, args);
		}
	}
	class ClassD extends ClassA {
		static __ks_new_0() {
			const o = Object.create(ClassD.prototype);
			o.__ks_init();
			return o;
		}
		__ks_cons_rt(that, args) {
			super.__ks_cons_rt.call(null, that, args);
		}
	}
};