const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	class LetterBox {
		static __ks_new_0(...args) {
			const o = Object.create(LetterBox.prototype);
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
		__ks_cons_0(messages) {
			this._messages = messages;
		}
		__ks_cons_rt(that, args) {
			const t0 = value => Type.isArray(value, Type.isString);
			if(args.length === 1) {
				if(t0(args[0])) {
					return LetterBox.prototype.__ks_cons_0.call(that, args[0]);
				}
			}
			throw Helper.badArgs();
		}
		build() {
			return this.__ks_func_build_rt.call(null, this, this, arguments);
		}
		__ks_func_build_0() {
			return (() => {
				const a = [];
				for(let __ks_1 = 0, __ks_0 = this._messages.length, message; __ks_1 < __ks_0; ++__ks_1) {
					message = this._messages[__ks_1];
					a.push(this.__ks_func_format_0(message));
				}
				return a;
			})();
		}
		__ks_func_build_rt(that, proto, args) {
			if(args.length === 0) {
				return proto.__ks_func_build_0.call(that);
			}
			throw Helper.badArgs();
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
};