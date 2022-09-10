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
		static __ks_sttc_foobar_0(x) {
			return "quxbaz";
		}
		static __ks_sttc_foobar_1(x) {
			return 42;
		}
		static foobar() {
			const t0 = Type.isNumber;
			const t1 = Type.isString;
			if(arguments.length === 1) {
				if(t0(arguments[0])) {
					return Foobar.__ks_sttc_foobar_1(arguments[0]);
				}
				if(t1(arguments[0])) {
					return Foobar.__ks_sttc_foobar_0(arguments[0]);
				}
			}
			throw Helper.badArgs();
		}
	}
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(a) {
		console.log(Foobar.__ks_sttc_foobar_0("foo"));
		console.log(Helper.toString(Foobar.__ks_sttc_foobar_1(0)));
		console.log(Helper.toString(Foobar.foobar(a)));
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};