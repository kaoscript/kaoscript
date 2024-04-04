const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const __ksType = {
		isNamed: value => Type.isDexObject(value, 1, 0, {name: Type.isString})
	};
	const __ks_Array = {};
	__ks_Array._im_splice = function(that, gens, ...args) {
		return __ks_Array.__ks_func_splice_rt(that, gens || {}, args);
	};
	__ks_Array.__ks_func_splice_rt = function(that, gens, args) {
		const t0 = (value => Type.isNumber(value) || Type.isNull(value));
		const t1 = gens.T || Type.isValue;
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(args.length === 0) {
			return that.splice.call(that, void 0, void 0, []);
		}
		if(args.length === 1) {
			if(t0(args[0])) {
				return that.splice.call(that, args[0], void 0, []);
			}
			if(t1(args[0])) {
				return that.splice.call(that, void 0, void 0, [args[0]]);
			}
			throw Helper.badArgs();
		}
		if(t0(args[0])) {
			if(t0(args[1])) {
				if(Helper.isVarargs(args, 0, args.length - 2, t1, pts = [2], 0) && te(pts, 1)) {
					return that.splice.call(that, args[0], args[1], ...Helper.getVarargs(args, 2, pts[1]));
				}
				throw Helper.badArgs();
			}
			if(Helper.isVarargs(args, 1, args.length - 1, t1, pts = [1], 0) && te(pts, 1)) {
				return that.splice.call(that, args[0], void 0, ...Helper.getVarargs(args, 1, pts[1]));
			}
			throw Helper.badArgs();
		}
		if(Helper.isVarargs(args, 2, args.length, t1, pts = [0], 0) && te(pts, 1)) {
			return that.splice.call(that, void 0, void 0, ...Helper.getVarargs(args, 0, pts[1]));
		}
		throw Helper.badArgs();
	};
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(values) {
		values.splice(0, 4, values[0]);
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = value => Type.isArray(value, __ksType.isNamed);
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};