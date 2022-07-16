const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	class Greetings {
		static __ks_new_0() {
			const o = Object.create(Greetings.prototype);
			o.__ks_init();
			o.__ks_cons_0();
			return o;
		}
		static __ks_new_1(...args) {
			const o = Object.create(Greetings.prototype);
			o.__ks_init();
			o.__ks_cons_1(...args);
			return o;
		}
		constructor() {
			this.__ks_init();
			this.__ks_cons_rt.call(null, this, arguments);
		}
		__ks_init() {
			this.__message = "";
		}
		__ks_cons_0() {
			Greetings.prototype.__ks_cons_1.call(this, "Hello!");
		}
		__ks_cons_1(__message) {
			this.__message = __message;
		}
		__ks_cons_rt(that, args) {
			const t0 = Type.isString;
			if(args.length === 0) {
				return Greetings.prototype.__ks_cons_0.call(that);
			}
			if(args.length === 1) {
				if(t0(args[0])) {
					return Greetings.prototype.__ks_cons_1.call(that, args[0]);
				}
			}
			throw Helper.badArgs();
		}
		message() {
			return this.__ks_func_message_rt.call(null, this, this, arguments);
		}
		__ks_func_message_0(prefix, suffix) {
			if(prefix === void 0 || prefix === null) {
				prefix = "";
			}
			if(suffix === void 0 || suffix === null) {
				suffix = "";
			}
			return Helper.concatString(prefix, this.__message, suffix);
		}
		__ks_func_message_rt(that, proto, args) {
			const t0 = () => true;
			const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
			let pts;
			if(args.length <= 2) {
				if(Helper.isVarargs(args, 0, 1, t0, pts = [0], 0) && Helper.isVarargs(args, 0, 1, t0, pts, 1) && te(pts, 2)) {
					return proto.__ks_func_message_0.call(that, Helper.getVararg(args, 0, pts[1]), Helper.getVararg(args, pts[1], pts[2]));
				}
			}
			throw Helper.badArgs();
		}
		greet_01() {
			return this.__ks_func_greet_01_rt.call(null, this, this, arguments);
		}
		__ks_func_greet_01_0(name) {
			return Helper.concatString(this.message(), "\nIt's nice to meet you, ", name, ".");
		}
		__ks_func_greet_01_rt(that, proto, args) {
			const t0 = Type.isValue;
			if(args.length === 1) {
				if(t0(args[0])) {
					return proto.__ks_func_greet_01_0.call(that, args[0]);
				}
			}
			throw Helper.badArgs();
		}
		greet_02() {
			return this.__ks_func_greet_02_rt.call(null, this, this, arguments);
		}
		__ks_func_greet_02_0(name) {
			return Helper.concatString(this.message(null, "Bye!"), "\nIt's nice to meet you, ", name, ".");
		}
		__ks_func_greet_02_rt(that, proto, args) {
			const t0 = Type.isValue;
			if(args.length === 1) {
				if(t0(args[0])) {
					return proto.__ks_func_greet_02_0.call(that, args[0]);
				}
			}
			throw Helper.badArgs();
		}
	}
};