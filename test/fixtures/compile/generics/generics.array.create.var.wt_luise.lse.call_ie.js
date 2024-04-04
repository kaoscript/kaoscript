const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const __ks_Array = {};
	__ks_Array._im_push = function(that, gens, ...args) {
		return __ks_Array.__ks_func_push_rt(that, gens || {}, args);
	};
	__ks_Array.__ks_func_push_rt = function(that, gens, args) {
		const t0 = gens.T || Type.isValue;
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(Helper.isVarargs(args, 0, args.length, t0, pts = [0], 0) && te(pts, 1)) {
			return that.push.call(that, ...Helper.getVarargs(args, 0, pts[1]));
		}
		throw Helper.badArgs();
	};
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(x, y) {
		const result = [x];
		console.log(result[0]);
		result.push(y);
		console.log(Helper.toString(result[0]));
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isString;
		const t1 = Type.isNumber;
		if(args.length === 2) {
			if(t0(args[0]) && t1(args[1])) {
				return foobar.__ks_0.call(that, args[0], args[1]);
			}
		}
		throw Helper.badArgs();
	};
};