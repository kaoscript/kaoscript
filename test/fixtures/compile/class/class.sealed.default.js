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
			this.__ks_cons_rt(arguments);
		}
		__ks_init() {
			this._message = "";
		}
		__ks_cons_0() {
			Greetings.prototype.__ks_cons_1.call(this, "Hello!");
		}
		__ks_cons_1(message) {
			this._message = Helper.assertString(message, 0);
		}
		__ks_cons_rt(args) {
			const t0 = Type.isValue;
			if(args.length === 0) {
				return Greetings.prototype.__ks_cons_0.call(this);
			}
			if(args.length === 1) {
				if(t0(args[0])) {
					return Greetings.prototype.__ks_cons_1.call(this, args[0]);
				}
			}
			throw Helper.badArgs();
		}
		__ks_func_greet_0(name) {
			return this._message + "\nIt's nice to meet you, " + name + ".";
		}
		greet(...args) {
			const t0 = Type.isValue;
			if(args.length === 1) {
				if(t0(args[0])) {
					return this.__ks_func_greet_0(args[0]);
				}
			}
			throw Helper.badArgs();
		}
	}
	let hello = Greetings.__ks_new_1("Hello world!");
	console.log(hello.__ks_func_greet_0("miss White"));
};