const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(x, y, z, values) {
		if(y === void 0 || y === null) {
			y = 1;
		}
		if(z === void 0 || z === null) {
			z = 2;
		}
		return 0;
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(args.length === 2) {
			if(t0(args[0]) && t0(args[1])) {
				return foobar.__ks_0.call(that, args[0], void 0, void 0, [args[1]]);
			}
			throw Helper.badArgs();
		}
		if(args.length === 3) {
			if(t0(args[0]) && t0(args[2])) {
				return foobar.__ks_0.call(that, args[0], args[1], void 0, [args[2]]);
			}
			throw Helper.badArgs();
		}
		if(args.length >= 4 && args.length <= 6) {
			if(t0(args[0]) && Helper.isVarargs(args, 1, 3, t0, pts = [3], 0) && te(pts, 1)) {
				return foobar.__ks_0.call(that, args[0], args[1], args[2], Helper.getVarargs(args, 3, pts[1]));
			}
		}
		throw Helper.badArgs();
	};
};