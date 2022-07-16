const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	class Weekday {
		static __ks_new_0(...args) {
			const o = Object.create(Weekday.prototype);
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
		__ks_cons_0(index, name) {
			this._index = index;
			this._name = name;
		}
		__ks_cons_rt(that, args) {
			const t0 = Type.isNumber;
			const t1 = Type.isString;
			if(args.length === 2) {
				if(t0(args[0]) && t1(args[1])) {
					return Weekday.prototype.__ks_cons_0.call(that, args[0], args[1]);
				}
			}
			throw Helper.badArgs();
		}
	}
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(day, month) {
		return 0;
	};
	foobar.__ks_1 = function(day, month) {
		return 1;
	};
	foobar.__ks_2 = function(day, month) {
		return 2;
	};
	foobar.__ks_3 = function(day, month) {
		return 3;
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isString;
		const t1 = Type.isNumber;
		const t2 = value => Type.isClassInstance(value, Weekday);
		if(args.length === 2) {
			if(t0(args[0])) {
				if(t1(args[1])) {
					return foobar.__ks_2.call(that, args[0], args[1]);
				}
				if(t0(args[1])) {
					return foobar.__ks_3.call(that, args[0], args[1]);
				}
				throw Helper.badArgs();
			}
			if(t2(args[0])) {
				if(t1(args[1])) {
					return foobar.__ks_0.call(that, args[0], args[1]);
				}
				if(t0(args[1])) {
					return foobar.__ks_1.call(that, args[0], args[1]);
				}
				throw Helper.badArgs();
			}
		}
		throw Helper.badArgs();
	};
	foobar.__ks_2("", -1);
};