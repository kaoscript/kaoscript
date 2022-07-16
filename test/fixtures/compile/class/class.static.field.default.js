const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	class Foo {
		static __ks_new_0(...args) {
			const o = Object.create(Foo.prototype);
			o.__ks_init();
			o.__ks_cons_0(...args);
			return o;
		}
		constructor() {
			this.__ks_init();
			this.__ks_cons_rt.call(null, this, arguments);
		}
		__ks_init() {
		}
		__ks_cons_0(name) {
			this.name = name;
		}
		__ks_cons_rt(that, args) {
			const t0 = Type.isString;
			if(args.length === 1) {
				if(t0(args[0])) {
					return Foo.prototype.__ks_cons_0.call(that, args[0]);
				}
			}
			throw Helper.badArgs();
		}
		qux() {
			return this.__ks_func_qux_rt.call(null, this, this, arguments);
		}
		__ks_func_qux_0(name) {
			Foo.bar = "Hello " + name;
		}
		__ks_func_qux_rt(that, proto, args) {
			const t0 = Type.isValue;
			if(args.length === 1) {
				if(t0(args[0])) {
					return proto.__ks_func_qux_0.call(that, args[0]);
				}
			}
			throw Helper.badArgs();
		}
	}
	Foo.bar = "Hello world!";
	console.log(Foo.bar);
	let foo = Foo.__ks_new_0("xyz");
	console.log(foo.name);
	return {
		Foo
	};
};