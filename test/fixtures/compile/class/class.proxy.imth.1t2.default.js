const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	class Hello {
		static __ks_new_0() {
			const o = Object.create(Hello.prototype);
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
		hello() {
			return this.__ks_func_hello_rt.call(null, this, this, arguments);
		}
		__ks_func_hello_0(x) {
		}
		__ks_func_hello_1(x) {
		}
		__ks_func_hello_rt(that, proto, args) {
			const t0 = Type.isNumber;
			const t1 = Type.isString;
			if(args.length === 1) {
				if(t0(args[0])) {
					return proto.__ks_func_hello_0.call(that, args[0]);
				}
				if(t1(args[0])) {
					return proto.__ks_func_hello_1.call(that, args[0]);
				}
			}
			throw Helper.badArgs();
		}
	}
	class Proxy {
		static __ks_new_0(...args) {
			const o = Object.create(Proxy.prototype);
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
		__ks_cons_0(component) {
			this._component = component;
		}
		__ks_cons_rt(that, args) {
			const t0 = value => Type.isClassInstance(value, Hello);
			if(args.length === 1) {
				if(t0(args[0])) {
					return Proxy.prototype.__ks_cons_0.call(that, args[0]);
				}
			}
			throw Helper.badArgs();
		}
		hello() {
			return this._component.__ks_func_hello_rt.call(null, this._component, this._component, arguments);
		}
		__ks_func_hello_rt(that, proto, args) {
			return proto.hello.apply(that, args);
		}
	}
	const p = Proxy.__ks_new_0(Hello.__ks_new_0());
	p._component.__ks_func_hello_1("");
	p._component.__ks_func_hello_0(42);
};