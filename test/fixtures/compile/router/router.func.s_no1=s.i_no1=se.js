const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar(kws, ...args) {
		return foobar.__ks_rt(this, args, kws);
	};
	foobar.__ks_0 = function(x, y) {
		return 1;
	};
	foobar.__ks_1 = function(x, y) {
		return 2;
	};
	foobar.__ks_rt = function(that, args, kws) {
		const t0 = Type.isString;
		const t1 = Type.isNumber;
		if(t0(kws.y)) {
			if(args.length === 1) {
				if(t1(args[0])) {
					return foobar.__ks_1.call(that, args[0], kws.y);
				}
				if(t0(args[0])) {
					return foobar.__ks_0.call(that, args[0], kws.y);
				}
			}
		}
		throw Helper.badArgs();
	};
};