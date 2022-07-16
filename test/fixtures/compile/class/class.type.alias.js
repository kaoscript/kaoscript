const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	class Person {
		static __ks_new_0() {
			const o = Object.create(Person.prototype);
			o.__ks_init();
			o.__ks_cons_0();
			return o;
		}
		constructor() {
			this.__ks_init();
			this.__ks_cons_rt.call(null, this, arguments);
		}
		__ks_init() {
			this._height = 0;
		}
		__ks_cons_0() {
		}
		__ks_cons_rt(that, args) {
			if(args.length === 0) {
				return Person.prototype.__ks_cons_0.call(that);
			}
			throw Helper.badArgs();
		}
		height() {
			return this.__ks_func_height_rt.call(null, this, this, arguments);
		}
		__ks_func_height_0() {
			return this._height;
		}
		__ks_func_height_1(height) {
			this._height = height;
			return this;
		}
		__ks_func_height_rt(that, proto, args) {
			const t0 = Type.isNumber;
			if(args.length === 0) {
				return proto.__ks_func_height_0.call(that);
			}
			if(args.length === 1) {
				if(t0(args[0])) {
					return proto.__ks_func_height_1.call(that, args[0]);
				}
			}
			throw Helper.badArgs();
		}
	}
};