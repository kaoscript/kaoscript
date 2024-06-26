const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	class Foo {
		static __ks_new_0() {
			const o = Object.create(Foo.prototype);
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
		y() {
			return this.__ks_func_y_rt.call(null, this, this, arguments);
		}
		__ks_func_y_0(x) {
			return false;
		}
		__ks_func_y_rt(that, proto, args) {
			const t0 = Type.isValue;
			if(args.length === 1) {
				if(t0(args[0])) {
					return proto.__ks_func_y_0.call(that, args[0]);
				}
			}
			throw Helper.badArgs();
		}
	}
	class Bar {
		static __ks_new_0() {
			const o = Object.create(Bar.prototype);
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
		y() {
			return this.__ks_func_y_rt.call(null, this, this, arguments);
		}
		__ks_func_y_0() {
		}
		__ks_func_y_1(x) {
			return 42;
		}
		__ks_func_y_rt(that, proto, args) {
			const t0 = Type.isValue;
			if(args.length === 0) {
				return proto.__ks_func_y_0.call(that);
			}
			if(args.length === 1) {
				if(t0(args[0])) {
					return proto.__ks_func_y_1.call(that, args[0]);
				}
			}
			throw Helper.badArgs();
		}
	}
	function foo() {
		return foo.__ks_rt(this, arguments);
	};
	foo.__ks_0 = function(x, y) {
		const z = Type.isClassInstance(y, Bar) ? y.__ks_func_y_1(x) : y.__ks_func_y_0(x);
		console.log(Helper.toString(z));
	};
	foo.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		const t1 = value => Type.isClassInstance(value, Bar) || Type.isClassInstance(value, Foo);
		if(args.length === 2) {
			if(t0(args[0]) && t1(args[1])) {
				return foo.__ks_0.call(that, args[0], args[1]);
			}
		}
		throw Helper.badArgs();
	};
};