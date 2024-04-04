const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const __ks_Array = {};
	__ks_Array._im_unshift = function(that, gens, ...args) {
		return __ks_Array.__ks_func_unshift_rt(that, gens || {}, args);
	};
	__ks_Array.__ks_func_unshift_rt = function(that, gens, args) {
		const t0 = gens.T || Type.isValue;
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(Helper.isVarargs(args, 0, args.length, t0, pts = [0], 0) && te(pts, 1)) {
			return that.unshift.call(that, ...Helper.getVarargs(args, 0, pts[1]));
		}
		throw Helper.badArgs();
	};
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function() {
		return [];
	};
	foobar.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return foobar.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
	function quxbaz() {
		return quxbaz.__ks_rt(this, arguments);
	};
	quxbaz.__ks_0 = function() {
		return [];
	};
	quxbaz.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return quxbaz.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
	const modifiers = quxbaz.__ks_0();
	modifiers.unshift(...quxbaz.__ks_0());
	const nodes = foobar.__ks_0();
	nodes.unshift(...foobar.__ks_0());
};