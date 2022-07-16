const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	let Integer = Helper.namespace(function() {
		function parse() {
			return parse.__ks_rt(this, arguments);
		};
		parse.__ks_0 = function(value = null, radix = null) {
			return parseInt(value, radix);
		};
		parse.__ks_rt = function(that, args) {
			const t0 = () => true;
			const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
			let pts;
			if(args.length <= 2) {
				if(Helper.isVarargs(args, 0, 1, t0, pts = [0], 0) && Helper.isVarargs(args, 0, 1, t0, pts, 1) && te(pts, 2)) {
					return parse.__ks_0.call(that, Helper.getVararg(args, 0, pts[1]), Helper.getVararg(args, pts[1], pts[2]));
				}
			}
			throw Helper.badArgs();
		};
		return {
			parse
		};
	});
	return {
		Integer
	};
};