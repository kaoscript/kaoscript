const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function curry(kws, ...args) {
		return curry.__ks_rt(this, args, kws);
	};
	curry.__ks_0 = function(fn, args, bind = null) {
		return 1;
	};
	curry.__ks_rt = function(that, args, kws) {
		const t0 = () => true;
		const t1 = Type.isString;
		const t2 = Type.isValue;
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(t0(kws.bind)) {
			if(args.length >= 1) {
				if(t1(args[0]) && Helper.isVarargs(args, 0, args.length - 1, t2, pts = [1], 0) && te(pts, 1)) {
					return curry.__ks_0.call(that, args[0], Helper.getVarargs(args, 1, pts[1]), kws.bind);
				}
			}
		}
		throw Helper.badArgs();
	};
	curry.__ks_0("", ["Hello "]);
};