const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const __ks_Array = {};
	__ks_Array._im_splice = function(that, gens, ...args) {
		return __ks_Array.__ks_func_splice_rt(that, gens || {}, args);
	};
	__ks_Array.__ks_func_splice_rt = function(that, gens, args) {
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
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(values) {
		values.splice(0, 1);
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isArray;
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};