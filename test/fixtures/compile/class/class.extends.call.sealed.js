const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const __ks_Object = {};
	__ks_Object.__ks_sttc_merge_0 = function(args) {
		return new OBJ();
	};
	__ks_Object._sm_merge = function() {
		const t0 = Type.isValue;
		const te = (pts, idx) => Helper.isUsingAllArgs(arguments, pts, idx);
		let pts;
		if(Helper.isVarargs(arguments, 0, arguments.length, t0, pts = [0], 0) && te(pts, 1)) {
			return __ks_Object.__ks_sttc_merge_0(Helper.getVarargs(arguments, 0, pts[1]));
		}
		if(Object.merge) {
			return Object.merge(...arguments);
		}
		throw Helper.badArgs();
	};
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
		__ks_cons_0(options) {
			this._x = options.x;
		}
		__ks_cons_rt(that, args) {
			const t0 = Type.isValue;
			if(args.length === 1) {
				if(t0(args[0])) {
					return Foobar.prototype.__ks_cons_0.call(that, args[0]);
				}
			}
			throw Helper.badArgs();
		}
	}
	class Quxbaz extends Foobar {
		static __ks_new_0(...args) {
			const o = Object.create(Quxbaz.prototype);
			o.__ks_init();
			o.__ks_cons_0(...args);
			return o;
		}
		__ks_cons_0(options = null) {
			Foobar.prototype.__ks_cons_0.call(this, __ks_Object.__ks_sttc_merge_0([(() => {
				const d = new OBJ();
				d.x = 0;
				d.y = 0;
				return d;
			})(), options]));
		}
		__ks_cons_rt(that, args) {
			if(args.length <= 1) {
				return Quxbaz.prototype.__ks_cons_0.call(that, args[0]);
			}
			throw Helper.badArgs();
		}
	}
};