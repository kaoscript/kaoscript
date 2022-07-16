const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(x, y) {
		if(x === void 0 || x === null) {
			x = "hello";
		}
		return 0;
	};
	foobar.__ks_1 = function(x, y, z) {
		if(x === void 0 || x === null) {
			x = "hello";
		}
		return 1;
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, void 0, args[0]);
			}
			throw Helper.badArgs();
		}
		if(args.length === 2) {
			if(t0(args[0])) {
				if(t0(args[1])) {
					return foobar.__ks_1.call(that, void 0, args[0], args[1]);
				}
			}
			if(t0(args[1])) {
				return foobar.__ks_0.call(that, args[0], args[1]);
			}
			throw Helper.badArgs();
		}
		if(args.length === 3) {
			if(t0(args[1]) && t0(args[2])) {
				return foobar.__ks_1.call(that, args[0], args[1], args[2]);
			}
		}
		throw Helper.badArgs();
	};
};