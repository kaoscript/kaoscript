const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	let bar = [];
	function foo() {
		return foo.__ks_rt(this, arguments);
	};
	foo.__ks_0 = function(args) {
		const foo = [...args];
	};
	foo.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(Helper.isVarargs(args, 0, args.length, t0, pts = [0], 0) && te(pts, 1)) {
			return foo.__ks_0.call(that, Helper.getVarargs(args, 0, pts[1]));
		}
		throw Helper.badArgs();
	};
};