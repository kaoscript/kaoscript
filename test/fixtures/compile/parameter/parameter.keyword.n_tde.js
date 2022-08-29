const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(__ks_class_1, __ks_default_1) {
		if(__ks_class_1 === void 0) {
			__ks_class_1 = null;
		}
		if(__ks_default_1 === void 0 || __ks_default_1 === null) {
			__ks_default_1 = 0;
		}
		console.log(__ks_class_1, __ks_default_1);
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = value => Type.isNumber(value) || Type.isNull(value);
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(args.length >= 1 && args.length <= 2) {
			if(Helper.isVarargs(args, 0, 1, t0, pts = [1], 0) && te(pts, 1)) {
				return foobar.__ks_0.call(that, args[0], Helper.getVararg(args, 1, pts[1]));
			}
		}
		throw Helper.badArgs();
	};
};