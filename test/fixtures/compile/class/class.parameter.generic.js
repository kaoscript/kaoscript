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
		static __ks_new_2(...args) {
			const o = Object.create(Greetings.prototype);
			o.__ks_init();
			o.__ks_cons_2(...args);
			return o;
		}
		constructor() {
			this.__ks_init();
			this.__ks_cons_rt.call(null, this, arguments);
		}
		__ks_init() {
			this._message = "Hello!";
		}
		__ks_cons_0() {
		}
		__ks_cons_1(message) {
			this._message = message;
		}
		__ks_cons_2(lines) {
			Greetings.prototype.__ks_cons_rt.call(null, this, [lines.join("\n")]);
		}
		__ks_cons_rt(that, args) {
			const t0 = Type.isString;
			const t1 = value => Type.isArray(value, Type.isString);
			if(args.length === 0) {
				return Greetings.prototype.__ks_cons_0.call(that);
			}
			if(args.length === 1) {
				if(t0(args[0])) {
					return Greetings.prototype.__ks_cons_1.call(that, args[0]);
				}
				if(t1(args[0])) {
					return Greetings.prototype.__ks_cons_2.call(that, args[0]);
				}
			}
			throw Helper.badArgs();
		}
	}
};