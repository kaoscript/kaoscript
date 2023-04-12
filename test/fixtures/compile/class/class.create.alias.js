const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	class Writer {
		static __ks_new_0(...args) {
			const o = Object.create(Writer.prototype);
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
		__ks_cons_0(line) {
			this._line = line;
		}
		__ks_cons_rt(that, args) {
			const t0 = Type.isClass;
			if(args.length === 1) {
				if(t0(args[0])) {
					return Writer.prototype.__ks_cons_0.call(that, args[0]);
				}
			}
			throw Helper.badArgs();
		}
		newLine() {
			return this.__ks_func_newLine_rt.call(null, this, this, arguments);
		}
		__ks_func_newLine_0(args) {
			return new this._line(...args);
		}
		__ks_func_newLine_rt(that, proto, args) {
			const t0 = Type.isValue;
			const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
			let pts;
			if(Helper.isVarargs(args, 0, args.length, t0, pts = [0], 0) && te(pts, 1)) {
				return proto.__ks_func_newLine_0.call(that, Helper.getVarargs(args, 0, pts[1]));
			}
			throw Helper.badArgs();
		}
	}
};