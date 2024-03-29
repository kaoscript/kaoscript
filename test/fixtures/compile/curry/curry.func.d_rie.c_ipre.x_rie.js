const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function add() {
		return add.__ks_rt(this, arguments);
	};
	add.__ks_0 = function(values) {
	};
	add.__ks_rt = function(that, args) {
		const t0 = Type.isNumber;
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(Helper.isVarargs(args, 0, args.length, t0, pts = [0], 0) && te(pts, 1)) {
			return add.__ks_0.call(that, Helper.getVarargs(args, 0, pts[1]));
		}
		throw Helper.badArgs();
	};
	const addOne = Helper.curry((that, fn, ...args) => {
		const t0 = Type.isNumber;
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(Helper.isVarargs(args, 0, args.length, t0, pts = [0], 0) && te(pts, 1)) {
			return fn[0](Helper.getVarargs(args, 0, pts[1]));
		}
		throw Helper.badArgs();
	}, (__ks_0) => add.__ks_0([1, ...__ks_0]));
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(values) {
		console.log(addOne.__ks_0(values));
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = value => Type.isArray(value, Type.isNumber);
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};