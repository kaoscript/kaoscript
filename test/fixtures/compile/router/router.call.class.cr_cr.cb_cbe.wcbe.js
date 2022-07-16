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
		}
		__ks_func_foobar_0(x) {
			if(Type.isClassInstance(x, ClassB)) {
				return this.__ks_func_foobar_1(x);
			}
			return super.__ks_func_foobar_0(x);
		}
		__ks_func_foobar_rt(that, proto, args) {
			const t0 = value => Type.isClassInstance(value, ClassB);
			if(args.length === 1) {
				if(t0(args[0])) {
					return proto.__ks_func_foobar_1.call(that, args[0]);
				}
			}
			return super.__ks_func_foobar_rt.call(null, that, ClassA.prototype, args);
		}
	}
	function quxbaz() {
		return quxbaz.__ks_rt(this, arguments);
	};
	quxbaz.__ks_0 = function(a) {
		a.__ks_func_foobar_1(a);
	};
	quxbaz.__ks_rt = function(that, args) {
		const t0 = value => Type.isClassInstance(value, ClassB);
		if(args.length === 1) {
			if(t0(args[0])) {
				return quxbaz.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};