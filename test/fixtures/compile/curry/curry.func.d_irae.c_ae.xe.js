const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function add() {
		return add.__ks_rt(this, arguments);
	};
	add.__ks_0 = function(x, args) {
	};
	add.__ks_rt = function(that, args) {
		const t0 = Type.isNumber;
		const t1 = Type.isValue;
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(args.length >= 1) {
			if(t0(args[0]) && Helper.isVarargs(args, 0, args.length - 1, t1, pts = [1], 0) && te(pts, 1)) {
				return add.__ks_0.call(that, args[0], Helper.getVarargs(args, 1, pts[1]));
			}
		}
		throw Helper.badArgs();
	};
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(x) {
		const addOne = () => add(x);
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};