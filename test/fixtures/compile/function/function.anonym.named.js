const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(x) {
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
	foobar.__ks_0(Helper.function(function(x) {
		return x;
	}, (that, fn, kws, ...args) => {
		const t0 = Type.isValue;
		if(t0(kws.x)) {
			if(args.length === 0) {
				return fn.call(null, kws.x);
			}
		}
		throw Helper.badArgs();
	}));
};