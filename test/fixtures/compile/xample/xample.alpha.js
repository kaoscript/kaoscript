require("kaoscript/register");
const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	var Float = require("../_/._float.ks.j5k8r9.ksb")().Float;
	var __ks_Number = require("../_/._number.ks.j5k8r9.ksb")().__ks_Number;
	function alpha() {
		return alpha.__ks_rt(this, arguments);
	};
	alpha.__ks_0 = function(n = null, percentage) {
		if(percentage === void 0 || percentage === null) {
			percentage = false;
		}
		let i = Float.parse.__ks_0(n);
		return Number.isNaN(i) ? 1 : __ks_Number.__ks_func_round_0.call(__ks_Number.__ks_func_limit_0.call((percentage === true) ? i / 100 : i, 0, 1), 3);
	};
	alpha.__ks_rt = function(that, args) {
		const t0 = () => true;
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(args.length <= 2) {
			if(Helper.isVarargs(args, 0, 1, t0, pts = [0], 0) && Helper.isVarargs(args, 0, 1, t0, pts, 1) && te(pts, 2)) {
				return alpha.__ks_0.call(that, Helper.getVararg(args, 0, pts[1]), Helper.getVararg(args, pts[1], pts[2]));
			}
		}
		throw Helper.badArgs();
	};
};