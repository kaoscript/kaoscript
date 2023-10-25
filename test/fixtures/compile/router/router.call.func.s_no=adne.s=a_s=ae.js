const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function curry(kws, ...args) {
		return curry.__ks_rt(this, args, kws);
	};
	curry.__ks_0 = function(fn, bind = null) {
		return 1;
	};
	curry.__ks_rt = function(that, args, kws) {
		const t0 = Type.any;
		const t1 = Type.isString;
		if(t0(kws.bind)) {
			if(args.length === 1) {
				if(t1(args[0])) {
					return curry.__ks_0.call(that, args[0], kws.bind);
				}
			}
		}
		throw Helper.badArgs();
	};
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(fn, bind) {
		curry({bind: bind}, fn);
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		if(args.length === 2) {
			if(t0(args[0]) && t0(args[1])) {
				return foobar.__ks_0.call(that, args[0], args[1]);
			}
		}
		throw Helper.badArgs();
	};
};