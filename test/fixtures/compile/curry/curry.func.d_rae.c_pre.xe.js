const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function add() {
		return add.__ks_rt(this, arguments);
	};
	add.__ks_0 = function(args) {
	};
	add.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(Helper.isVarargs(args, 0, args.length, t0, pts = [0], 0) && te(pts, 1)) {
			return add.__ks_0.call(that, Helper.getVarargs(args, 0, pts[1]));
		}
		throw Helper.badArgs();
	};
	const addOne = Helper.curry((that, fn, ...args) => {
		const t0 = Type.isValue;
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(Helper.isVarargs(args, 0, args.length, t0, pts = [0], 0) && te(pts, 1)) {
			return fn[0](Helper.getVarargs(args, 0, pts[1]));
		}
		throw Helper.badArgs();
	}, (__ks_0) => add.__ks_0(__ks_0));
};