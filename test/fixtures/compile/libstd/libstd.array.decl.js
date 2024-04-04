const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const __ksStd_a = {};
	__ksStd_a._im_indexOf = function(that, gens, ...args) {
		return __ksStd_a.__ks_func_indexOf_rt(that, gens || {}, args);
	};
	__ksStd_a.__ks_func_indexOf_rt = function(that, gens, args) {
		const t0 = gens.T || Type.any;
		const t1 = (value => Type.isNumber(value) || Type.isNull(value));
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(args.length >= 1 && args.length <= 2) {
			if(t0(args[0]) && Helper.isVarargs(args, 0, 1, t1, pts = [1], 0) && te(pts, 1)) {
				return that.indexOf.call(that, args[0], Helper.getVararg(args, 1, pts[1]));
			}
		}
		throw Helper.badArgs();
	};
	__ksStd_a._im_push = function(that, gens, ...args) {
		return __ksStd_a.__ks_func_push_rt(that, gens || {}, args);
	};
	__ksStd_a.__ks_func_push_rt = function(that, gens, args) {
		const t0 = gens.T || Type.any;
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(Helper.isVarargs(args, 0, args.length, t0, pts = [0], 0) && te(pts, 1)) {
			return that.push.call(that, ...Helper.getVarargs(args, 0, pts[1]));
		}
		throw Helper.badArgs();
	};
	__ksStd_a._im_splice = function(that, gens, ...args) {
		return __ksStd_a.__ks_func_splice_rt(that, gens || {}, args);
	};
	__ksStd_a.__ks_func_splice_rt = function(that, gens, args) {
		const t0 = gens.T || Type.any;
		const t1 = (value => Type.isNumber(value) || Type.isNull(value));
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(args.length === 0) {
			return that.splice.call(that, void 0, void 0, []);
		}
		if(args.length === 1) {
			if(t0(args[0])) {
				return that.splice.call(that, void 0, void 0, [args[0]]);
			}
			if(t1(args[0])) {
				return that.splice.call(that, args[0], void 0, []);
			}
			throw Helper.badArgs();
		}
		if(Helper.isVarargs(args, 2, args.length, t0, pts = [0], 0) && te(pts, 1)) {
			return that.splice.call(that, void 0, void 0, ...Helper.getVarargs(args, 0, pts[1]));
		}
		if(t1(args[0])) {
			if(Helper.isVarargs(args, 1, args.length - 1, t0, pts = [1], 0) && te(pts, 1)) {
				return that.splice.call(that, args[0], void 0, ...Helper.getVarargs(args, 1, pts[1]));
			}
			if(t1(args[1]) && Helper.isVarargs(args, 0, args.length - 2, t0, pts = [2], 0) && te(pts, 1)) {
				return that.splice.call(that, args[0], args[1], ...Helper.getVarargs(args, 2, pts[1]));
			}
			throw Helper.badArgs();
		}
		throw Helper.badArgs();
	};
	__ksStd_a._im_unshift = function(that, gens, ...args) {
		return __ksStd_a.__ks_func_unshift_rt(that, gens || {}, args);
	};
	__ksStd_a.__ks_func_unshift_rt = function(that, gens, args) {
		const t0 = gens.T || Type.any;
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(Helper.isVarargs(args, 0, args.length, t0, pts = [0], 0) && te(pts, 1)) {
			return that.unshift.call(that, ...Helper.getVarargs(args, 0, pts[1]));
		}
		throw Helper.badArgs();
	};
	return {
		__ksStd_a
	};
};