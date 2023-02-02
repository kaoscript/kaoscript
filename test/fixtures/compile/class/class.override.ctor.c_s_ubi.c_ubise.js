const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	class Foobar {
		static __ks_new_0(...args) {
			const o = Object.create(Foobar.prototype);
			o.__ks_init();
			o.__ks_cons_0(...args);
			return o;
		}
		static __ks_new_1(...args) {
			const o = Object.create(Foobar.prototype);
			o.__ks_init();
			o.__ks_cons_1(...args);
			return o;
		}
		constructor() {
			this.__ks_init();
			this.__ks_cons_rt.call(null, this, arguments);
		}
		__ks_init() {
		}
		__ks_cons_0(value) {
			this.value = value;
		}
		__ks_cons_1(value) {
			this.value = Helper.toString(value);
		}
		__ks_cons_rt(that, args) {
			const t0 = Type.isString;
			const t1 = value => Type.isBoolean(value) || Type.isNumber(value);
			if(args.length === 1) {
				if(t0(args[0])) {
					return Foobar.prototype.__ks_cons_0.call(that, args[0]);
				}
				if(t1(args[0])) {
					return Foobar.prototype.__ks_cons_1.call(that, args[0]);
				}
			}
			throw Helper.badArgs();
		}
	}
	class Quxbaz extends Foobar {
		static __ks_new_0(...args) {
			const o = Object.create(Quxbaz.prototype);
			o.__ks_init();
			o.__ks_cons_0(...args);
			return o;
		}
		__ks_cons_0(value) {
			Foobar.prototype.__ks_cons_rt.call(null, this, [value]);
		}
		__ks_cons_rt(that, args) {
			const t0 = value => Type.isBoolean(value) || Type.isNumber(value) || Type.isString(value);
			if(args.length === 1) {
				if(t0(args[0])) {
					return Quxbaz.prototype.__ks_cons_0.call(that, args[0]);
				}
			}
			throw Helper.badArgs();
		}
	}
};