const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(value = null) {
		return 0;
	};
	foobar.__ks_1 = function(args) {
		return 1;
	};
	foobar.__ks_2 = function(value, args) {
		return 2;
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		const t1 = Type.isBoolean;
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(args.length <= 1) {
			return foobar.__ks_0.call(that, args[0]);
		}
		if(t0(args[0])) {
			if(Helper.isVarargs(args, 1, args.length - 1, t1, pts = [1], 0) && te(pts, 1)) {
				return foobar.__ks_2.call(that, args[0], Helper.getVarargs(args, 1, pts[1]));
			}
			if(Helper.isVarargs(args, 1, args.length - 1, t0, pts = [1], 0) && te(pts, 1)) {
				return foobar.__ks_1.call(that, Helper.getVarargs(args, 0, pts[1]));
			}
		}
		throw Helper.badArgs();
	};
};