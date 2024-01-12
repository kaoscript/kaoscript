const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(array) {
		if(array === void 0 || array === null) {
			array = [];
		}
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = value => Type.isArray(value) || Type.isNull(value);
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(args.length <= 1) {
			if(Helper.isVarargs(args, 0, 1, t0, pts = [0], 0) && te(pts, 1)) {
				return foobar.__ks_0.call(that, Helper.getVararg(args, 0, pts[1]));
			}
		}
		throw Helper.badArgs();
	};
	const condition = true;
	const values = [1, 2, 3];
	foobar.__ks_0(condition ? (() => {
		const a = [];
		for(let __ks_1 = 0, __ks_0 = values.length, value; __ks_1 < __ks_0; ++__ks_1) {
			value = values[__ks_1];
			a.push(value);
		}
		return a;
	})() : null);
};