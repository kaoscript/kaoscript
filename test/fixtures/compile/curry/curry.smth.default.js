const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	class Message {
		static __ks_new_0() {
			const o = Object.create(Message.prototype);
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
		static __ks_sttc_build_0(lines) {
			return lines.join("\n");
		}
		static build() {
			const t0 = Type.isValue;
			const te = (pts, idx) => Helper.isUsingAllArgs(arguments, pts, idx);
			let pts;
			if(Helper.isVarargs(arguments, 0, arguments.length, t0, pts = [0], 0) && te(pts, 1)) {
				return Message.__ks_sttc_build_0(Helper.getVarargs(arguments, 0, pts[1]));
			}
			throw Helper.badArgs();
		}
	}
	const hello = Helper.curry((that, fn, ...args) => {
		const t0 = Type.isValue;
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(Helper.isVarargs(args, 0, args.length, t0, pts = [0], 0) && te(pts, 1)) {
			return fn[0](Helper.getVarargs(args, 0, pts[1]));
		}
		throw Helper.badArgs();
	}, (__ks_0) => Message.__ks_sttc_build_0(["Hello!", ...__ks_0]));
	function print() {
		return print.__ks_rt(this, arguments);
	};
	print.__ks_0 = function(name, printer) {
		return printer("It's nice to meet you, " + name + ".");
	};
	print.__ks_rt = function(that, args) {
		const t0 = Type.isString;
		const t1 = Type.isFunction;
		if(args.length === 2) {
			if(t0(args[0]) && t1(args[1])) {
				return print.__ks_0.call(that, args[0], args[1]);
			}
		}
		throw Helper.badArgs();
	};
	print.__ks_0("miss White", hello);
};