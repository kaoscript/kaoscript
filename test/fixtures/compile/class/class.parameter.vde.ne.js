const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(x) {
		if(x === void 0 || x === null) {
			x = "foobar";
		}
	};
	foobar.__ks_rt = function(that, args) {
		if(args.length === 1) {
			return foobar.__ks_0.call(that, args[0]);
		}
		throw Helper.badArgs();
	};
	class Master {
		static __ks_new_0() {
			const o = Object.create(Master.prototype);
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
		foobar() {
			return this.__ks_func_foobar_rt.call(null, this, this, arguments);
		}
		__ks_func_foobar_0(x) {
			if(x === void 0 || x === null) {
				x = "foobar";
			}
		}
		__ks_func_foobar_rt(that, proto, args) {
			if(args.length === 1) {
				return proto.__ks_func_foobar_0.call(that, args[0]);
			}
			throw Helper.badArgs();
		}
	}
	const m = Master.__ks_new_0();
	m.__ks_func_foobar_0(null);
};