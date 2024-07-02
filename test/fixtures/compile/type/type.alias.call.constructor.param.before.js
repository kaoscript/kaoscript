const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const Quxbaz = Helper.alias(value => Type.isDexObject(value, 1, 0, {name: Type.isString}));
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function() {
		return Corge.__ks_new_0();
	};
	foobar.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return foobar.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
	const Foobar = Helper.alias(value => Type.isDexObject(value, 1, 0, {name: Type.isString}));
	class Corge {
		static __ks_new_0(...args) {
			const o = Object.create(Corge.prototype);
			o.__ks_init();
			o.__ks_cons_0(...args);
			return o;
		}
		constructor() {
			this.__ks_init();
			this.__ks_cons_rt.call(null, this, arguments);
		}
		__ks_init() {
		}
		__ks_cons_0(foobars, quxbazs) {
			if(foobars === void 0 || foobars === null) {
				foobars = [];
			}
			if(quxbazs === void 0 || quxbazs === null) {
				quxbazs = [];
			}
			this._foobars = foobars;
			this._quxbazs = quxbazs;
		}
		__ks_cons_rt(that, args) {
			const t0 = value => Type.isArray(value, Foobar.is) || Type.isNull(value);
			const t1 = value => Type.isArray(value, Quxbaz.is) || Type.isNull(value);
			const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
			let pts;
			if(args.length <= 2) {
				if(Helper.isVarargs(args, 0, 1, t0, pts = [0], 0) && Helper.isVarargs(args, 0, 1, t1, pts, 1) && te(pts, 2)) {
					return Corge.prototype.__ks_cons_0.call(that, Helper.getVararg(args, 0, pts[1]), Helper.getVararg(args, pts[1], pts[2]));
				}
			}
			throw Helper.badArgs();
		}
	}
};