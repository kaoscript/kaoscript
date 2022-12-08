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
	}
	class Quxbaz {
		static __ks_new_0() {
			const o = Object.create(Quxbaz.prototype);
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
	}
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(a, b, c, d) {
		return a;
	};
	foobar.__ks_1 = function(a, b, c, d) {
		return b;
	};
	foobar.__ks_2 = function(a, b, c, d) {
		return c;
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isString;
		const t1 = Type.isValue;
		const t2 = Type.isObject;
		const t3 = value => Type.isClassInstance(value, Quxbaz);
		const t4 = value => Type.isClassInstance(value, Foobar);
		if(args.length === 4) {
			if(t0(args[0])) {
				if(t1(args[1]) && t2(args[2])) {
					if(t0(args[3])) {
						return foobar.__ks_2.call(that, args[0], args[1], args[2], args[3]);
					}
					if(t3(args[3])) {
						return foobar.__ks_1.call(that, args[0], args[1], args[2], args[3]);
					}
				}
			}
			if(t1(args[0]) && t2(args[1]) && t4(args[2]) && t3(args[3])) {
				return foobar.__ks_0.call(that, args[0], args[1], args[2], args[3]);
			}
		}
		throw Helper.badArgs();
	};
};