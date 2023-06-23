const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function $format() {
		return $format.__ks_rt(this, arguments);
	};
	$format.__ks_0 = function(message) {
		return message.toUpperCase();
	};
	$format.__ks_rt = function(that, args) {
		const t0 = Type.isString;
		if(args.length === 1) {
			if(t0(args[0])) {
				return $format.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	class LetterBox {
		static __ks_new_0(...args) {
			const o = Object.create(LetterBox.prototype);
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
		__ks_cons_0(messages) {
			this._messages = messages;
		}
		__ks_cons_rt(that, args) {
			const t0 = value => Type.isArray(value, Type.isString);
			if(args.length === 1) {
				if(t0(args[0])) {
					return LetterBox.prototype.__ks_cons_0.call(that, args[0]);
				}
			}
			throw Helper.badArgs();
		}
		build_01() {
			return this.__ks_func_build_01_rt.call(null, this, this, arguments);
		}
		__ks_func_build_01_0() {
			return this._messages.map(Helper.function((message) => {
				return this.format(message);
			}, (fn, ...args) => {
				const t0 = Type.isValue;
				if(args.length === 1) {
					if(t0(args[0])) {
						return fn.call(this, args[0]);
					}
				}
				throw Helper.badArgs();
			}));
		}
		__ks_func_build_01_rt(that, proto, args) {
			if(args.length === 0) {
				return proto.__ks_func_build_01_0.call(that);
			}
			throw Helper.badArgs();
		}
		build_02() {
			return this.__ks_func_build_02_rt.call(null, this, this, arguments);
		}
		__ks_func_build_02_0() {
			return this._messages.map(Helper.function((message, foo, bar) => {
				if(foo === void 0 || foo === null) {
					foo = 42;
				}
				return this.format(message);
			}, (fn, ...args) => {
				const t0 = Type.isValue;
				if(args.length === 2) {
					if(t0(args[0]) && t0(args[1])) {
						return fn.call(this, args[0], void 0, args[1]);
					}
					throw Helper.badArgs();
				}
				if(args.length === 3) {
					if(t0(args[0]) && t0(args[2])) {
						return fn.call(this, args[0], args[1], args[2]);
					}
				}
				throw Helper.badArgs();
			}));
		}
		__ks_func_build_02_rt(that, proto, args) {
			if(args.length === 0) {
				return proto.__ks_func_build_02_0.call(that);
			}
			throw Helper.badArgs();
		}
		build_03() {
			return this.__ks_func_build_03_rt.call(null, this, this, arguments);
		}
		__ks_func_build_03_0() {
			return this._messages.map(Helper.function((message, foo = null, bar) => {
				return this.format(message);
			}, (fn, ...args) => {
				const t0 = Type.isValue;
				if(args.length === 2) {
					if(t0(args[0]) && t0(args[1])) {
						return fn.call(this, args[0], void 0, args[1]);
					}
					throw Helper.badArgs();
				}
				if(args.length === 3) {
					if(t0(args[0]) && t0(args[2])) {
						return fn.call(this, args[0], args[1], args[2]);
					}
				}
				throw Helper.badArgs();
			}));
		}
		__ks_func_build_03_rt(that, proto, args) {
			if(args.length === 0) {
				return proto.__ks_func_build_03_0.call(that);
			}
			throw Helper.badArgs();
		}
		build_04() {
			return this.__ks_func_build_04_rt.call(null, this, this, arguments);
		}
		__ks_func_build_04_0() {
			return this._messages.map(Helper.function((message, foo, bar) => {
				return this.format(message);
			}, (fn, ...args) => {
				const t0 = Type.isValue;
				const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
				let pts;
				if(args.length >= 2) {
					if(t0(args[0]) && Helper.isVarargs(args, 0, args.length - 2, t0, pts = [1], 0) && Helper.isVarargs(args, 1, 1, t0, pts, 1) && te(pts, 2)) {
						return fn.call(this, args[0], Helper.getVarargs(args, 1, pts[1]), Helper.getVararg(args, pts[1], pts[2]));
					}
				}
				throw Helper.badArgs();
			}));
		}
		__ks_func_build_04_rt(that, proto, args) {
			if(args.length === 0) {
				return proto.__ks_func_build_04_0.call(that);
			}
			throw Helper.badArgs();
		}
		build_05() {
			return this.__ks_func_build_05_rt.call(null, this, this, arguments);
		}
		__ks_func_build_05_0() {
			return this._messages.map(Helper.function((message, foo, bar) => {
				return $format(message);
			}, (fn, ...args) => {
				const t0 = Type.isValue;
				const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
				let pts;
				if(args.length >= 2) {
					if(t0(args[0]) && Helper.isVarargs(args, 0, args.length - 2, t0, pts = [1], 0) && Helper.isVarargs(args, 1, 1, t0, pts, 1) && te(pts, 2)) {
						return fn.call(null, args[0], Helper.getVarargs(args, 1, pts[1]), Helper.getVararg(args, pts[1], pts[2]));
					}
				}
				throw Helper.badArgs();
			}));
		}
		__ks_func_build_05_rt(that, proto, args) {
			if(args.length === 0) {
				return proto.__ks_func_build_05_0.call(that);
			}
			throw Helper.badArgs();
		}
		format() {
			return this.__ks_func_format_rt.call(null, this, this, arguments);
		}
		__ks_func_format_0(message) {
			return message.toUpperCase();
		}
		__ks_func_format_rt(that, proto, args) {
			const t0 = Type.isString;
			if(args.length === 1) {
				if(t0(args[0])) {
					return proto.__ks_func_format_0.call(that, args[0]);
				}
			}
			throw Helper.badArgs();
		}
		static __ks_sttc_compose_00_0(box) {
			return box._messages.map(Helper.function((message) => {
				return box.format(message);
			}, (fn, ...args) => {
				const t0 = Type.isValue;
				if(args.length === 1) {
					if(t0(args[0])) {
						return fn.call(null, args[0]);
					}
				}
				throw Helper.badArgs();
			}));
		}
		static compose_00() {
			const t0 = Type.isValue;
			if(arguments.length === 1) {
				if(t0(arguments[0])) {
					return LetterBox.__ks_sttc_compose_00_0(arguments[0]);
				}
			}
			throw Helper.badArgs();
		}
		static __ks_sttc_compose_01_0(box) {
			return box._messages.map(Helper.function((message, foo, bar) => {
				return box.format(message);
			}, (fn, ...args) => {
				const t0 = Type.isValue;
				const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
				let pts;
				if(args.length >= 2) {
					if(t0(args[0]) && Helper.isVarargs(args, 0, args.length - 2, t0, pts = [1], 0) && Helper.isVarargs(args, 1, 1, t0, pts, 1) && te(pts, 2)) {
						return fn.call(null, args[0], Helper.getVarargs(args, 1, pts[1]), Helper.getVararg(args, pts[1], pts[2]));
					}
				}
				throw Helper.badArgs();
			}));
		}
		static compose_01() {
			const t0 = Type.isValue;
			if(arguments.length === 1) {
				if(t0(arguments[0])) {
					return LetterBox.__ks_sttc_compose_01_0(arguments[0]);
				}
			}
			throw Helper.badArgs();
		}
	}
};