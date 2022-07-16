const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(value, args) {
		return "Array";
	};
	foobar.__ks_1 = function(value, args) {
		return "String";
	};
	foobar.__ks_2 = function(value, args) {
		return "Any";
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isArray;
		const t1 = Type.isValue;
		const t2 = Type.isString;
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(args.length >= 1) {
			if(t0(args[0])) {
				if(Helper.isVarargs(args, 0, args.length - 1, t1, pts = [1], 0) && te(pts, 1)) {
					return foobar.__ks_0.call(that, args[0], Helper.getVarargs(args, 1, pts[1]));
				}
			}
			if(t2(args[0])) {
				if(Helper.isVarargs(args, 0, args.length - 1, t1, pts = [1], 0) && te(pts, 1)) {
					return foobar.__ks_1.call(that, args[0], Helper.getVarargs(args, 1, pts[1]));
				}
			}
			if(t1(args[0]) && Helper.isVarargs(args, 0, args.length - 1, t1, pts = [1], 0) && te(pts, 1)) {
				return foobar.__ks_2.call(that, args[0], Helper.getVarargs(args, 1, pts[1]));
			}
		}
		throw Helper.badArgs();
	};
	return {
		foobar
	};
};