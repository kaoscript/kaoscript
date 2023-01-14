const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(x, y, z) {
		Helper.assertLoop(1, "x", x, "y", y, 0, "z", z);
		if(x >= y) {
			for(let i = x; i >= y; i -= z) {
				return i;
			}
		}
		else {
			return 0;
		}
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		if(args.length === 3) {
			if(t0(args[0]) && t0(args[1]) && t0(args[2])) {
				return foobar.__ks_0.call(that, args[0], args[1], args[2]);
			}
		}
		throw Helper.badArgs();
	};
};