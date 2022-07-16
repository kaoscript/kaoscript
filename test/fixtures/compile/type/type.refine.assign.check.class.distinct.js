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
	function bar() {
		return bar.__ks_rt(this, arguments);
	};
	bar.__ks_0 = function(x) {
		return "";
	};
	bar.__ks_1 = function(x) {
		return 42;
	};
	bar.__ks_rt = function(that, args) {
		const t0 = value => Type.isClassInstance(value, Bar);
		const t1 = value => Type.isClassInstance(value, Foo);
		if(args.length === 1) {
			if(t0(args[0])) {
				return bar.__ks_1.call(that, args[0]);
			}
			if(t1(args[0])) {
				return bar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	let x = Foo.__ks_new_0();
	console.log(Helper.toString(bar(x)));
	let y = Bar.__ks_new_0();
	console.log(Helper.toString(bar.__ks_1(y)));
	let z = Bar.__ks_new_0();
	console.log(Helper.toString(bar.__ks_1(z)));
};