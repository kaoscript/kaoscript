const {Dictionary, Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	let foo = (() => {
		const d = new Dictionary();
		d.bar = (() => {
			const __ks_rt = (...args) => {
				const t0 = value => Type.isString(value) || Type.isNull(value);
				const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
				let pts;
				if(args.length <= 1) {
					if(Helper.isVarargs(args, 0, 1, t0, pts = [0], 0) && te(pts, 1)) {
						return __ks_rt.__ks_0.call(null, Helper.getVararg(args, 0, pts[1]));
					}
				}
				throw Helper.badArgs();
			};
			__ks_rt.__ks_0 = function(name = null) {
				let n = 0;
			};
			return __ks_rt;
		})();
		return d;
	})();
};