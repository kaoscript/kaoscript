const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	class Greetings {
		static __ks_new_0(...args) {
			const o = Object.create(Greetings.prototype);
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
		__ks_cons_0(message) {
			if(message === void 0 || message === null) {
				message = "Hello!";
			}
			this._message = message;
		}
		__ks_cons_rt(that, args) {
			const t0 = value => Type.isString(value) || Type.isNull(value);
			const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
			let pts;
			if(args.length <= 1) {
				if(Helper.isVarargs(args, 0, 1, t0, pts = [0], 0) && te(pts, 1)) {
					return Greetings.prototype.__ks_cons_0.call(that, Helper.getVararg(args, 0, pts[1]));
				}
			}
			throw Helper.badArgs();
		}
		greet() {
			return this.__ks_func_greet_rt.call(null, this, this, arguments);
		}
		__ks_func_greet_0(name) {
			return this._message + "\nIt's nice to meet you, " + name + ".";
		}
		__ks_func_greet_rt(that, proto, args) {
			const t0 = Type.isValue;
			if(args.length === 1) {
				if(t0(args[0])) {
					return proto.__ks_func_greet_0.call(that, args[0]);
				}
			}
			throw Helper.badArgs();
		}
	}
	let hello = Greetings.__ks_new_0("Hello world!");
	console.log(hello.__ks_func_greet_0("miss White"));
};