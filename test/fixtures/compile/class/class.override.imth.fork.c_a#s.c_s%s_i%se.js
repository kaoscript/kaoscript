const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	class Foobar {
		static __ks_new_0() {
			const o = Object.create(Foobar.prototype);
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
		message() {
			return this.__ks_func_message_rt.call(null, this, this, arguments);
		}
		__ks_func_message_0(x) {
			return x.toString();
		}
		__ks_func_message_rt(that, proto, args) {
			const t0 = Type.isValue;
			if(args.length === 1) {
				if(t0(args[0])) {
					return proto.__ks_func_message_0.call(that, args[0]);
				}
			}
			throw Helper.badArgs();
		}
	}
	class Quxbaz extends Foobar {
		static __ks_new_0() {
			const o = Object.create(Quxbaz.prototype);
			o.__ks_init();
			return o;
		}
		__ks_cons_rt(that, args) {
			super.__ks_cons_rt.call(null, that, args);
		}
		__ks_func_message_1(x) {
			return x;
		}
		__ks_func_message_2(x) {
			return Helper.toString(x);
		}
		__ks_func_message_0(x) {
			if(Type.isString(x)) {
				return this.__ks_func_message_1(x);
			}
			if(Type.isNumber(x)) {
				return this.__ks_func_message_2(x);
			}
			return super.__ks_func_message_0(x);
		}
		__ks_func_message_rt(that, proto, args) {
			const t0 = Type.isNumber;
			const t1 = Type.isString;
			if(args.length === 1) {
				if(t0(args[0])) {
					return proto.__ks_func_message_2.call(that, args[0]);
				}
				if(t1(args[0])) {
					return proto.__ks_func_message_1.call(that, args[0]);
				}
			}
			return super.__ks_func_message_rt.call(null, that, Foobar.prototype, args);
		}
	}
};