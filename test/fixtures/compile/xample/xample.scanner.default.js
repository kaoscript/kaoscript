const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const Token = Helper.enum(Number, {
		INVALID: 0
	});
	class Scanner {
		static __ks_new_0() {
			const o = Object.create(Scanner.prototype);
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
		match() {
			return this.__ks_func_match_rt.call(null, this, this, arguments);
		}
		__ks_func_match_0(tokens) {
			const c = this.skip(tokens.length);
			return Token.INVALID;
		}
		__ks_func_match_rt(that, proto, args) {
			const t0 = value => Type.isArray(value, value => Type.isEnumInstance(value, Token));
			const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
			let pts;
			if(Helper.isVarargs(args, 0, args.length, t0, pts = [0], 0) && te(pts, 1)) {
				return proto.__ks_func_match_0.call(that, Helper.getVarargs(args, 0, pts[1]));
			}
			throw Helper.badArgs();
		}
		skip() {
			return this.__ks_func_skip_rt.call(null, this, this, arguments);
		}
		__ks_func_skip_0(index) {
		}
		__ks_func_skip_rt(that, proto, args) {
			const t0 = Type.isValue;
			if(args.length === 1) {
				if(t0(args[0])) {
					return proto.__ks_func_skip_0.call(that, args[0]);
				}
			}
			throw Helper.badArgs();
		}
	}
};