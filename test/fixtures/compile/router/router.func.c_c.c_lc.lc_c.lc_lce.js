const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
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
	foobar.__ks_0 = function(aType, bType) {
		return foobar.__ks_3([aType], [bType]);
	};
	foobar.__ks_1 = function(aType, bTypes) {
		return foobar.__ks_3([aType], bTypes);
	};
	foobar.__ks_2 = function(aTypes, bType) {
		return foobar.__ks_3(aTypes, [bType]);
	};
	foobar.__ks_3 = function(aTypes, bTypes) {
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = value => Type.isClassInstance(value, Quxbaz);
		const t1 = value => Type.isArray(value, value => Type.isClassInstance(value, Quxbaz));
		if(args.length === 2) {
			if(t0(args[0])) {
				if(t0(args[1])) {
					return foobar.__ks_0.call(that, args[0], args[1]);
				}
				if(t1(args[1])) {
					return foobar.__ks_1.call(that, args[0], args[1]);
				}
				throw Helper.badArgs();
			}
			if(t1(args[0])) {
				if(t0(args[1])) {
					return foobar.__ks_2.call(that, args[0], args[1]);
				}
				if(t1(args[1])) {
					return foobar.__ks_3.call(that, args[0], args[1]);
				}
				throw Helper.badArgs();
			}
		}
		throw Helper.badArgs();
	};
};