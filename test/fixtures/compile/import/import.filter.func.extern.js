require("kaoscript/register");
const {Helper} = require("@kaoscript/runtime");
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
		toString() {
			return this.__ks_func_toString_rt.call(null, this, this, arguments);
		}
		__ks_func_toString_0() {
			return "foobar";
		}
		__ks_func_toString_rt(that, proto, args) {
			if(args.length === 0) {
				return proto.__ks_func_toString_0.call(that);
			}
			throw Helper.badArgs();
		}
	}
	var foobar = require("../export/.export.filter.func.extern.ks.j5k8r9.ksb")().foobar;
	console.log(foobar.__ks_0("foobar"));
	const x = Foobar.__ks_new_0();
	console.log(x.__ks_func_toString_0());
	console.log(foobar.__ks_1(x).__ks_func_toString_0());
};