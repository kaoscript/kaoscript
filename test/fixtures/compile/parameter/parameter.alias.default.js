const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const __ksType = {
		isCoord: value => Type.isDexObject(value, 1, 0, {x: Type.isNumber, y: Type.isNumber})
	};
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(first, last) {
		const {x, y} = first;
		if(last === void 0 || last === null) {
			last = first;
		}
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = __ksType.isCoord;
		const t1 = value => __ksType.isCoord(value) || Type.isNull(value);
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(args.length >= 1 && args.length <= 2) {
			if(t0(args[0]) && Helper.isVarargs(args, 0, 1, t1, pts = [1], 0) && te(pts, 1)) {
				return foobar.__ks_0.call(that, args[0], Helper.getVararg(args, 1, pts[1]));
			}
		}
		throw Helper.badArgs();
	};
};