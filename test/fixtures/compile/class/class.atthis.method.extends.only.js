const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	class Messenger {
		static __ks_new_0() {
			const o = Object.create(Messenger.prototype);
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
		__ks_func_message_0() {
			return "Hello!";
		}
		__ks_func_message_rt(that, proto, args) {
			if(args.length === 0) {
				return proto.__ks_func_message_0.call(that);
			}
			throw Helper.badArgs();
		}
	}
	class Greetings extends Messenger {
		static __ks_new_0() {
			const o = Object.create(Greetings.prototype);
			o.__ks_init();
			return o;
		}
		__ks_cons_rt(that, args) {
			super.__ks_cons_rt.call(null, that, args);
		}
		greet() {
			return this.__ks_func_greet_rt.call(null, this, this, arguments);
		}
		__ks_func_greet_0(name) {
			return Helper.concatString(this.__ks_func_message_0(), "\nIt's nice to meet you, ", name, ".");
		}
		__ks_func_greet_rt(that, proto, args) {
			const t0 = Type.isValue;
			if(args.length === 1) {
				if(t0(args[0])) {
					return proto.__ks_func_greet_0.call(that, args[0]);
				}
			}
			if(super.__ks_func_greet_rt) {
				return super.__ks_func_greet_rt.call(null, that, Messenger.prototype, args);
			}
			throw Helper.badArgs();
		}
	}
};