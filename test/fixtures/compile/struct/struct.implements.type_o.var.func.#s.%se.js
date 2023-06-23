const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const __ksType = {
		isTypeA: value => Type.isDexObject(value, 1, 0, {foobar: Type.isFunction})
	};
	const ClassA = Helper.struct(function(foobar) {
		if(foobar === void 0 || foobar === null) {
			foobar = Helper.function(() => {
				return "";
			}, (fn, ...args) => {
				if(args.length === 0) {
					return fn.call(null);
				}
				throw Helper.badArgs();
			});
		}
		const _ = new OBJ();
		_.foobar = foobar;
		return _;
	}, function(__ks_new, args) {
		const t0 = Type.isFunction;
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(args.length <= 1) {
			if(Helper.isVarargs(args, 0, 1, t0, pts = [0], 0) && te(pts, 1)) {
				return __ks_new(Helper.getVararg(args, 0, pts[1]));
			}
		}
		throw Helper.badArgs();
	});
};