const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	class LetterBox {
		static __ks_new_0() {
			const o = Object.create(LetterBox.prototype);
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
		format() {
			return this.__ks_func_format_rt.call(null, this, this, arguments);
		}
		__ks_func_format_0(message) {
			return message.toUpperCase();
		}
		__ks_func_format_rt(that, proto, args) {
			const t0 = Type.isString;
			if(args.length === 1) {
				if(t0(args[0])) {
					return proto.__ks_func_format_0.call(that, args[0]);
				}
			}
			throw Helper.badArgs();
		}
	}
	LetterBox.prototype.__ks_func_format_0 = function(message) {
		return message.toLowerCase();
	};
};