const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	class Foobar {
		static __ks_new_0(...args) {
			const o = Object.create(Foobar.prototype);
			o.__ks_init();
			o.__ks_cons_0(...args);
			return o;
		}
		constructor() {
			this.__ks_init();
			this.__ks_cons_rt.call(null, this, arguments);
		}
		__ks_init() {
			this._index = null;
		}
		__ks_cons_0(name, index, value) {
			if(index === void 0) {
				index = null;
			}
			if(value === void 0) {
				value = null;
			}
			this._name = name;
			this._index = index;
			this._value = value;
		}
		__ks_cons_rt(that, args) {
			const t0 = Type.isString;
			const t1 = value => Type.isNumber(value) || Type.isNull(value);
			if(args.length === 3) {
				if(t0(args[0]) && t1(args[1])) {
					return Foobar.prototype.__ks_cons_0.call(that, args[0], args[1], args[2]);
				}
			}
			throw Helper.badArgs();
		}
	}
};