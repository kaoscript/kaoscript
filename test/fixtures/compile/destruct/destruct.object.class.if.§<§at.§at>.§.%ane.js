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
			this._x = 0;
			this._y = 0;
		}
		__ks_cons_rt(that, args) {
			if(args.length !== 0) {
				throw Helper.badArgs();
			}
		}
		foobar() {
			return this.__ks_func_foobar_rt.call(null, this, this, arguments);
		}
		__ks_func_foobar_0(data) {
			if(data === void 0) {
				data = null;
			}
			let color;
			if(Type.isValue(data) ? (Helper.assertDexObject(data, 1, 0, {coord: value => Type.isDexObject(value, 1, 0, {x: Type.isNumber, y: Type.isNumber}), color: Type.isValue}), {coord: {x: this._x, y: this._y}, color} = data, true) : false) {
			}
		}
		__ks_func_foobar_rt(that, proto, args) {
			if(args.length === 1) {
				return proto.__ks_func_foobar_0.call(that, args[0]);
			}
			throw Helper.badArgs();
		}
	}
};