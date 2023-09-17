const {Helper} = require("@kaoscript/runtime");
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
		foo() {
			return this.__ks_func_foo_rt.call(null, this, this, arguments);
		}
		__ks_func_foo_0() {
			return "";
		}
		__ks_func_foo_rt(that, proto, args) {
			if(args.length === 0) {
				return proto.__ks_func_foo_0.call(that);
			}
			throw Helper.badArgs();
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
		bar() {
			return this.__ks_func_bar_rt.call(null, this, this, arguments);
		}
		__ks_func_bar_0() {
			return "";
		}
		__ks_func_bar_rt(that, proto, args) {
			if(args.length === 0) {
				return proto.__ks_func_bar_0.call(that);
			}
			if(super.__ks_func_bar_rt) {
				return super.__ks_func_bar_rt.call(null, that, Foo.prototype, args);
			}
			throw Helper.badArgs();
		}
	}
	function bar() {
		return bar.__ks_rt(this, arguments);
	};
	bar.__ks_0 = function() {
		return Bar.__ks_new_0();
	};
	bar.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return bar.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
	let x = Foo.__ks_new_0();
	console.log(x.__ks_func_foo_0());
	console.log(Helper.toString(x.bar()));
	x = bar.__ks_0();
	console.log(x.__ks_func_foo_0());
	console.log(x.__ks_func_bar_0());
	let y = Bar.__ks_new_0();
	console.log(y.__ks_func_foo_0());
	console.log(y.__ks_func_bar_0());
	let z = Bar.__ks_new_0();
	console.log(z.__ks_func_foo_0());
	console.log(z.__ks_func_bar_0());
	return {
		Foo,
		Bar,
		x,
		y,
		z
	};
};