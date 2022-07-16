const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	class Greetings {
		static __ks_new_0() {
			const o = Object.create(Greetings.prototype);
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
		foo() {
			return this.__ks_func_foo_rt.call(null, this, this, arguments);
		}
		__ks_func_foo_0(args) {
			console.log(args);
		}
		__ks_func_foo_rt(that, proto, args) {
			const t0 = Type.isValue;
			const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
			let pts;
			if(Helper.isVarargs(args, 0, args.length, t0, pts = [0], 0) && te(pts, 1)) {
				return proto.__ks_func_foo_0.call(that, Helper.getVarargs(args, 0, pts[1]));
			}
			throw Helper.badArgs();
		}
		bar() {
			return this.__ks_func_bar_rt.call(null, this, this, arguments);
		}
		__ks_func_bar_0() {
		}
		__ks_func_bar_1(name, messages) {
			console.log(name, messages);
		}
		__ks_func_bar_rt(that, proto, args) {
			const t0 = Type.isValue;
			const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
			let pts;
			if(args.length === 0) {
				return proto.__ks_func_bar_0.call(that);
			}
			if(t0(args[0]) && Helper.isVarargs(args, 0, args.length - 1, t0, pts = [1], 0) && te(pts, 1)) {
				return proto.__ks_func_bar_1.call(that, args[0], Helper.getVarargs(args, 1, pts[1]));
			}
			throw Helper.badArgs();
		}
		baz() {
			return this.__ks_func_baz_rt.call(null, this, this, arguments);
		}
		__ks_func_baz_0() {
		}
		__ks_func_baz_1(foo, bar, qux) {
			if(bar === void 0 || bar === null) {
				bar = "bar";
			}
			if(qux === void 0 || qux === null) {
				qux = "qux";
			}
			console.log(foo, bar, qux);
		}
		__ks_func_baz_rt(that, proto, args) {
			const t0 = Type.isValue;
			const t1 = () => true;
			const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
			let pts;
			if(args.length === 0) {
				return proto.__ks_func_baz_0.call(that);
			}
			if(args.length >= 1 && args.length <= 3) {
				if(t0(args[0])) {
					if(Helper.isVarargs(args, 0, 1, t1, pts = [1], 0) && Helper.isVarargs(args, 0, 1, t1, pts, 1) && te(pts, 2)) {
						return proto.__ks_func_baz_1.call(that, args[0], Helper.getVararg(args, 1, pts[1]), Helper.getVararg(args, pts[1], pts[2]));
					}
				}
			}
			throw Helper.badArgs();
		}
		qux() {
			return this.__ks_func_qux_rt.call(null, this, this, arguments);
		}
		__ks_func_qux_0() {
		}
		__ks_func_qux_1(name, priority, messages) {
			if(priority === void 0 || priority === null) {
				priority = 1;
			}
			console.log(name, priority, messages);
		}
		__ks_func_qux_rt(that, proto, args) {
			const t0 = Type.isValue;
			const t1 = () => true;
			const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
			let pts;
			if(args.length === 0) {
				return proto.__ks_func_qux_0.call(that);
			}
			if(t0(args[0]) && Helper.isVarargs(args, 0, 1, t1, pts = [1], 0) && Helper.isVarargs(args, 0, args.length - 1, t0, pts, 1) && te(pts, 2)) {
				return proto.__ks_func_qux_1.call(that, args[0], Helper.getVararg(args, 1, pts[1]), Helper.getVarargs(args, pts[1], pts[2]));
			}
			throw Helper.badArgs();
		}
		corge() {
			return this.__ks_func_corge_rt.call(null, this, this, arguments);
		}
		__ks_func_corge_0(name) {
			console.log(name);
		}
		__ks_func_corge_1(name, message, priority) {
			if(priority === void 0 || priority === null) {
				priority = 1;
			}
			console.log(name, priority, message);
		}
		__ks_func_corge_rt(that, proto, args) {
			const t0 = Type.isValue;
			if(args.length === 1) {
				if(t0(args[0])) {
					return proto.__ks_func_corge_0.call(that, args[0]);
				}
				throw Helper.badArgs();
			}
			if(args.length >= 2 && args.length <= 3) {
				if(t0(args[0]) && t0(args[1])) {
					return proto.__ks_func_corge_1.call(that, args[0], args[1], args[2]);
				}
			}
			throw Helper.badArgs();
		}
		grault() {
			return this.__ks_func_grault_rt.call(null, this, this, arguments);
		}
		__ks_func_grault_0(name) {
			console.log(name);
		}
		__ks_func_grault_1(name, priority, message) {
			if(priority === void 0 || priority === null) {
				priority = 1;
			}
			console.log(name, priority, message);
		}
		__ks_func_grault_rt(that, proto, args) {
			const t0 = Type.isValue;
			if(args.length === 1) {
				if(t0(args[0])) {
					return proto.__ks_func_grault_0.call(that, args[0]);
				}
				throw Helper.badArgs();
			}
			if(args.length === 2) {
				if(t0(args[0]) && t0(args[1])) {
					return proto.__ks_func_grault_1.call(that, args[0], void 0, args[1]);
				}
				throw Helper.badArgs();
			}
			if(args.length === 3) {
				if(t0(args[0]) && t0(args[2])) {
					return proto.__ks_func_grault_1.call(that, args[0], args[1], args[2]);
				}
			}
			throw Helper.badArgs();
		}
		garply() {
			return this.__ks_func_garply_rt.call(null, this, this, arguments);
		}
		__ks_func_garply_0(name) {
			console.log(name);
		}
		__ks_func_garply_1(name, message, priority) {
			if(priority === void 0 || priority === null) {
				priority = 1;
			}
			console.log(name, priority, message);
		}
		__ks_func_garply_2(name, priority, messages) {
			if(priority === void 0 || priority === null) {
				priority = 1;
			}
			console.log(name, priority, messages);
		}
		__ks_func_garply_rt(that, proto, args) {
			const t0 = Type.isString;
			const t1 = Type.isArray;
			const t2 = value => Type.isNumber(value) || Type.isNull(value);
			if(args.length === 1) {
				if(t0(args[0])) {
					return proto.__ks_func_garply_0.call(that, args[0]);
				}
				throw Helper.badArgs();
			}
			if(args.length === 2) {
				if(t0(args[0])) {
					if(t1(args[1])) {
						return proto.__ks_func_garply_2.call(that, args[0], void 0, args[1]);
					}
					if(t0(args[1])) {
						return proto.__ks_func_garply_1.call(that, args[0], args[1], void 0);
					}
					throw Helper.badArgs();
				}
				throw Helper.badArgs();
			}
			if(args.length === 3) {
				if(t0(args[0])) {
					if(t0(args[1])) {
						if(t2(args[2])) {
							return proto.__ks_func_garply_1.call(that, args[0], args[1], args[2]);
						}
						throw Helper.badArgs();
					}
					if(t2(args[1]) && t1(args[2])) {
						return proto.__ks_func_garply_2.call(that, args[0], args[1], args[2]);
					}
					throw Helper.badArgs();
				}
			}
			throw Helper.badArgs();
		}
		waldo() {
			return this.__ks_func_waldo_rt.call(null, this, this, arguments);
		}
		__ks_func_waldo_0() {
		}
		__ks_func_waldo_1(name, messages, priority) {
			if(priority === void 0 || priority === null) {
				priority = 1;
			}
			console.log(name, priority, messages);
		}
		__ks_func_waldo_rt(that, proto, args) {
			const t0 = Type.isValue;
			const t1 = () => true;
			const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
			let pts;
			if(args.length === 0) {
				return proto.__ks_func_waldo_0.call(that);
			}
			if(t0(args[0]) && Helper.isVarargs(args, 0, args.length - 2, t0, pts = [1], 0) && Helper.isVarargs(args, 0, 1, t1, pts, 1) && te(pts, 2)) {
				return proto.__ks_func_waldo_1.call(that, args[0], Helper.getVarargs(args, 1, pts[1]), Helper.getVararg(args, pts[1], pts[2]));
			}
			throw Helper.badArgs();
		}
	}
};