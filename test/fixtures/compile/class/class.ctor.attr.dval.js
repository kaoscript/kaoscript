const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	class Foobar {
		static __ks_new_0(...args) {
			const o = Object.create(Foobar.prototype);
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
		__ks_cons_0(parent, type = Type.isValue(parent) ? parent.__ks_func_type_0() : null) {
			if(parent === void 0) {
				parent = null;
			}
			this._parent = parent;
			this._type = type;
		}
		__ks_cons_rt(that, args) {
			const t0 = value => Type.isClassInstance(value, Foobar) || Type.isNull(value);
			const t1 = value => Type.isString(value) || Type.isNull(value);
			const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
			let pts;
			if(args.length >= 1 && args.length <= 2) {
				if(t0(args[0]) && Helper.isVarargs(args, 0, 1, t1, pts = [1], 0) && te(pts, 1)) {
					return Foobar.prototype.__ks_cons_0.call(that, args[0], Helper.getVararg(args, 1, pts[1]));
				}
			}
			throw Helper.badArgs();
		}
		type() {
			return this.__ks_func_type_rt.call(null, this, this, arguments);
		}
		__ks_func_type_0() {
			return this._type;
		}
		__ks_func_type_rt(that, proto, args) {
			if(args.length === 0) {
				return proto.__ks_func_type_0.call(that);
			}
			throw Helper.badArgs();
		}
	}
};