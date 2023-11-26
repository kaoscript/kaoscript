const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const FontWeight = Helper.enum(Number, 0, "Bold", 0, "Normal", 1);
	const Style = Helper.tuple(function(fontWeight) {
		if(fontWeight === void 0 || fontWeight === null) {
			fontWeight = FontWeight.Normal;
		}
		return [fontWeight];
	}, function(__ks_new, args) {
		const t0 = value => Type.isEnumInstance(value, FontWeight) || Type.isNull(value);
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