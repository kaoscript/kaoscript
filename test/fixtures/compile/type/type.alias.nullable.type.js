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
		static __ks_sttc_get_0(x) {
			return Foobar.__ks_new_0();
		}
		static get() {
			const t0 = Type.isString;
			if(arguments.length === 1) {
				if(t0(arguments[0])) {
					return Foobar.__ks_sttc_get_0(arguments[0]);
				}
			}
			throw Helper.badArgs();
		}
	}
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(x = null) {
		if(!Type.isValue(x)) {
			x = Foobar.__ks_sttc_get_0("foobar");
		}
		if(Type.isString(x)) {
			x = Foobar.__ks_sttc_get_0(x);
		}
		quxbaz.__ks_0(x);
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = value => Type.isString(value) || Type.isClassInstance(value, Foobar) || Type.isNull(value);
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(args.length <= 1) {
			if(Helper.isVarargs(args, 0, 1, t0, pts = [0], 0) && te(pts, 1)) {
				return foobar.__ks_0.call(that, Helper.getVararg(args, 0, pts[1]));
			}
		}
		throw Helper.badArgs();
	};
	function quxbaz() {
		return quxbaz.__ks_rt(this, arguments);
	};
	quxbaz.__ks_0 = function(x) {
	};
	quxbaz.__ks_rt = function(that, args) {
		const t0 = value => Type.isClassInstance(value, Foobar);
		if(args.length === 1) {
			if(t0(args[0])) {
				return quxbaz.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};