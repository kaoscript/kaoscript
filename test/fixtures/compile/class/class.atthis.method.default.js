const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	class Greetings {
		static __ks_new_0() {
			const o = Object.create(Greetings.prototype);
			o.__ks_init();
			o.__ks_cons_0();
			return o;
		}
		static __ks_new_1(...args) {
			const o = Object.create(Greetings.prototype);
			o.__ks_init();
			o.__ks_cons_1(...args);
			return o;
		}
		constructor() {
			this.__ks_init();
			this.__ks_cons_rt.call(null, this, arguments);
		}
		__ks_init() {
			this._message = "";
		}
		__ks_cons_0() {
			Greetings.prototype.__ks_cons_1.call(this, "Hello!");
		}
		__ks_cons_1(message) {
			this._message = message;
		}
		__ks_cons_rt(that, args) {
			const t0 = Type.isString;
			if(args.length === 0) {
				return Greetings.prototype.__ks_cons_0.call(that);
			}
			if(args.length === 1) {
				if(t0(args[0])) {
					return Greetings.prototype.__ks_cons_1.call(that, args[0]);
				}
			}
			throw Helper.badArgs();
		}
		message() {
			return this.__ks_func_message_rt.call(null, this, this, arguments);
		}
		__ks_func_message_0(message) {
			this._message = message;
			return this;
		}
		__ks_func_message_1() {
			return this._message;
		}
		__ks_func_message_rt(that, proto, args) {
			const t0 = Type.isString;
			if(args.length === 0) {
				return proto.__ks_func_message_1.call(that);
			}
			if(args.length === 1) {
				if(t0(args[0])) {
					return proto.__ks_func_message_0.call(that, args[0]);
				}
			}
			throw Helper.badArgs();
		}
		greet_01() {
			return this.__ks_func_greet_01_rt.call(null, this, this, arguments);
		}
		__ks_func_greet_01_0(name) {
			return Helper.concatString(this._message, "\nIt's nice to meet you, ", name, ".");
		}
		__ks_func_greet_01_rt(that, proto, args) {
			const t0 = Type.isValue;
			if(args.length === 1) {
				if(t0(args[0])) {
					return proto.__ks_func_greet_01_0.call(that, args[0]);
				}
			}
			throw Helper.badArgs();
		}
		greet_02() {
			return this.__ks_func_greet_02_rt.call(null, this, this, arguments);
		}
		__ks_func_greet_02_0(name) {
			return Helper.concatString(this.__ks_func_message_1(), "\nIt's nice to meet you, ", name, ".");
		}
		__ks_func_greet_02_rt(that, proto, args) {
			const t0 = Type.isValue;
			if(args.length === 1) {
				if(t0(args[0])) {
					return proto.__ks_func_greet_02_0.call(that, args[0]);
				}
			}
			throw Helper.badArgs();
		}
		greet_03() {
			return this.__ks_func_greet_03_rt.call(null, this, this, arguments);
		}
		__ks_func_greet_03_0(name) {
			return Helper.concatString(this._message.toUpperCase(), "\nIt's nice to meet you, ", name, ".");
		}
		__ks_func_greet_03_rt(that, proto, args) {
			const t0 = Type.isValue;
			if(args.length === 1) {
				if(t0(args[0])) {
					return proto.__ks_func_greet_03_0.call(that, args[0]);
				}
			}
			throw Helper.badArgs();
		}
	}
};