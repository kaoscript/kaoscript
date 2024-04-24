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
			this._value = null;
		}
		__ks_cons_rt(that, args) {
			if(args.length !== 0) {
				throw Helper.badArgs();
			}
		}
		value() {
			return this.__ks_func_value_rt.call(null, this, this, arguments);
		}
		__ks_func_value_0() {
			return this._value;
		}
		__ks_func_value_rt(that, proto, args) {
			if(args.length === 0) {
				return proto.__ks_func_value_0.call(that);
			}
			throw Helper.badArgs();
		}
	}
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(x) {
		let value, __ks_0;
		if((Type.isValue(__ks_0 = x.__ks_func_value_0()) ? (value = __ks_0, true) : false)) {
			value.print();
		}
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = value => Type.isClassInstance(value, Foobar);
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};