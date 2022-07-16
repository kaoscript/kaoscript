const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const __ks_Date = {};
	__ks_Date.__ks_new_0 = function() {
		return __ks_Date.__ks_cons_0.call(new Date(), );
	};
	__ks_Date.__ks_cons_0 = function() {
		return this;
	};
	__ks_Date.new = function() {
		if(arguments.length === 0) {
			return __ks_Date.__ks_cons_0.call(new Date());
		}
		return new Date(...arguments);
	};
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(args) {
		const d = __ks_Date.new(...args);
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(Helper.isVarargs(args, 0, args.length, t0, pts = [0], 0) && te(pts, 1)) {
			return foobar.__ks_0.call(that, Helper.getVarargs(args, 0, pts[1]));
		}
		throw Helper.badArgs();
	};
};