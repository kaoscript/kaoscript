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
		__ks_func_hello_0(name) {
			return "Hello " + name + ".";
		}
		__ks_func_hello_rt(that, proto, args) {
			const t0 = Type.isString;
			if(args.length === 1) {
				if(t0(args[0])) {
					return proto.__ks_func_hello_0.call(that, args[0]);
				}
			}
			throw Helper.badArgs();
		}
	}
	class Proxy {
		static __ks_new_0() {
			const o = Object.create(Proxy.prototype);
			o.__ks_init();
			return o;
		}
		constructor() {
			this.__ks_init();
			this.__ks_cons_rt.call(null, this, arguments);
		}
		__ks_init() {
			this._component = Hello.__ks_new_0();
		}
		__ks_cons_rt(that, args) {
			if(args.length !== 0) {
				throw Helper.badArgs();
			}
		}
		hello() {
			return this._component.__ks_func_hello_rt.call(null, this._component, this._component, arguments);
		}
		__ks_func_hello_rt(that, proto, args) {
			return proto.hello.apply(that, args);
		}
	}
	const proxy = Proxy.__ks_new_0();
	console.log(proxy._component.__ks_func_hello_0("Joe"));
	return {
		Proxy
	};
};