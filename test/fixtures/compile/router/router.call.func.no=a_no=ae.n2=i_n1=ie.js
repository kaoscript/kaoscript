const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar(kws, ...args) {
		return foobar.__ks_rt(this, args, kws);
	};
	foobar.__ks_0 = function(x, y) {
		return 1;
	};
	foobar.__ks_rt = function(that, args, kws) {
		const t0 = Type.isValue;
		if(t0(kws.x) && t0(kws.y)) {
			if(args.length === 0) {
				return foobar.__ks_0.call(that, kws.x, kws.y);
			}
		}
		throw Helper.badArgs();
	};
	foobar.__ks_0(0, 1);
};