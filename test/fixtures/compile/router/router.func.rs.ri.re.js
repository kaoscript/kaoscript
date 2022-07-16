const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(strings) {
		return 0;
	};
	foobar.__ks_1 = function(numbers) {
		return 1;
	};
	foobar.__ks_2 = function(args) {
		return 2;
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isNumber;
		const t1 = Type.isString;
		const t2 = Type.isValue;
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(args.length === 0) {
			return foobar.__ks_2.call(that, []);
		}
		if(Helper.isVarargs(args, 1, args.length, t0, pts = [0], 0) && te(pts, 1)) {
			return foobar.__ks_1.call(that, Helper.getVarargs(args, 0, pts[1]));
		}
		if(Helper.isVarargs(args, 1, args.length, t1, pts = [0], 0) && te(pts, 1)) {
			return foobar.__ks_0.call(that, Helper.getVarargs(args, 0, pts[1]));
		}
		if(Helper.isVarargs(args, 1, args.length, t2, pts = [0], 0) && te(pts, 1)) {
			return foobar.__ks_2.call(that, Helper.getVarargs(args, 0, pts[1]));
		}
		throw Helper.badArgs();
	};
};