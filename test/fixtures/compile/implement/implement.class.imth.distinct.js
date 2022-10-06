const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	class Foobar {
		static __ks_new_0() {
			const o = Object.create(Foobar.prototype);
			o.__ks_init();
			return o;
		}
		constructor() {
			this.__ks_init();
			this.__ks_cons_rt.call(null, this, arguments);
		}
		__ks_init() {
		}
		__ks_cons_rt(that, args) {
			if(args.length !== 0) {
				throw Helper.badArgs();
			}
		}
	}
	Foobar.prototype.__ks_func_foobar_0 = function(value) {
	};
	Foobar.prototype.__ks_func_foobar_1 = function(values) {
	};
	Foobar.prototype.__ks_func_foobar_rt = function(that, proto, args) {
		const t0 = Type.isValue;
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(args.length === 1) {
			if(t0(args[0])) {
				return proto.__ks_func_foobar_0.call(that, args[0]);
			}
			throw Helper.badArgs();
		}
		if(Helper.isVarargs(args, 0, args.length, t0, pts = [0], 0) && te(pts, 1)) {
			return proto.__ks_func_foobar_1.call(that, Helper.getVarargs(args, 0, pts[1]));
		}
		throw Helper.badArgs();
	};
	Foobar.prototype.foobar = function() {
		return this.__ks_func_foobar_rt.call(null, this, this, arguments);
	};
};