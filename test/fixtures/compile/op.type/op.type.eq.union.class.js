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
	}
	class Bar extends Foo {
		static __ks_new_0() {
			const o = Object.create(Bar.prototype);
			o.__ks_init();
			return o;
		}
		__ks_cons_rt(that, args) {
			super.__ks_cons_rt.call(null, that, args);
		}
	}
	class Qux extends Foo {
		static __ks_new_0() {
			const o = Object.create(Qux.prototype);
			o.__ks_init();
			return o;
		}
		__ks_cons_rt(that, args) {
			super.__ks_cons_rt.call(null, that, args);
		}
	}
	function foo() {
		return foo.__ks_rt(this, arguments);
	};
	foo.__ks_0 = function(x) {
		if(Type.isClassInstance(x, Bar) || Type.isClassInstance(x, Qux)) {
		}
		else {
		}
	};
	foo.__ks_rt = function(that, args) {
		const t0 = value => Type.isClassInstance(value, Foo);
		if(args.length === 1) {
			if(t0(args[0])) {
				return foo.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};