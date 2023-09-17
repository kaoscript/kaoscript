const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foo() {
		return foo.__ks_rt(this, arguments);
	};
	foo.__ks_0 = function(x) {
	};
	foo.__ks_rt = function(that, args) {
		const t0 = value => Type.isClassInstance(value, ClassA);
		if(args.length === 1) {
			if(t0(args[0])) {
				return foo.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	class ClassZ {
		static __ks_new_0() {
			const o = Object.create(ClassZ.prototype);
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
		static __ks_sttc_foo_0(x) {
		}
		static foo() {
			const t0 = value => Type.isClassInstance(value, ClassA);
			if(arguments.length === 1) {
				if(t0(arguments[0])) {
					return ClassZ.__ks_sttc_foo_0(arguments[0]);
				}
			}
			throw Helper.badArgs();
		}
	}
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
	}
};