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
		static __ks_sttc_message_0(x) {
			return x.toString();
		}
		static message() {
			const t0 = Type.isValue;
			if(arguments.length === 1) {
				if(t0(arguments[0])) {
					return Foobar.__ks_sttc_message_0(arguments[0]);
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
		static __ks_sttc_message_1(x) {
			return x;
		}
		static __ks_sttc_message_2(x) {
			return Helper.toString(x);
		}
		static __ks_sttc_message_0() {
			return Foobar.__ks_sttc_message_0(...arguments);
		}
		static message() {
			const t0 = Type.isNumber;
			const t1 = Type.isString;
			const t2 = Type.isValue;
			if(arguments.length === 1) {
				if(t0(arguments[0])) {
					return Quxbaz.__ks_sttc_message_2(arguments[0]);
				}
				if(t1(arguments[0])) {
					return Quxbaz.__ks_sttc_message_1(arguments[0]);
				}
				if(t2(arguments[0])) {
					return Quxbaz.__ks_sttc_message_0(arguments[0]);
				}
			}
			return Foobar.message.apply(null, arguments);
		}
	}
};