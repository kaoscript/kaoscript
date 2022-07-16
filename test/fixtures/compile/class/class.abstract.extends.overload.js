const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	class AbstractGreetings {
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
	class Greetings extends AbstractGreetings {
		static __ks_new_0() {
			const o = Object.create(Greetings.prototype);
			o.__ks_init();
			return o;
		}
		__ks_init() {
			super.__ks_init();
			this._message = "";
		}
		__ks_cons_rt(that, args) {
			super.__ks_cons_rt.call(null, that, args);
		}
		message() {
			return this.__ks_func_message_rt.call(null, this, this, arguments);
		}
		__ks_func_message_0() {
			return this._message;
		}
		__ks_func_message_1(message) {
			this._message = message;
			return this;
		}
		__ks_func_message_rt(that, proto, args) {
			const t0 = Type.isString;
			if(args.length === 0) {
				return proto.__ks_func_message_0.call(that);
			}
			if(args.length === 1) {
				if(t0(args[0])) {
					return proto.__ks_func_message_1.call(that, args[0]);
				}
			}
			if(super.__ks_func_message_rt) {
				return super.__ks_func_message_rt.call(null, that, AbstractGreetings.prototype, args);
			}
			throw Helper.badArgs();
		}
	}
};