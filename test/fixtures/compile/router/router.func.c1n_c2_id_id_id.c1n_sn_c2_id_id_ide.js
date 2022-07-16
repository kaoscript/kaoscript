const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	class ClassA {
		static __ks_new_0() {
			const o = Object.create(ClassA.prototype);
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
	}
	class ClassB {
		static __ks_new_0() {
			const o = Object.create(ClassB.prototype);
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
	}
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(a, b, c, d, e) {
		if(a === void 0) {
			a = null;
		}
		if(c === void 0 || c === null) {
			c = 1;
		}
		if(d === void 0 || d === null) {
			d = 1;
		}
		if(e === void 0 || e === null) {
			e = 0;
		}
		return 0;
	};
	foobar.__ks_1 = function(a, n, b, c, d, e) {
		if(a === void 0) {
			a = null;
		}
		if(n === void 0) {
			n = null;
		}
		if(c === void 0 || c === null) {
			c = 1;
		}
		if(d === void 0 || d === null) {
			d = 1;
		}
		if(e === void 0 || e === null) {
			e = 0;
		}
		return 1;
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = value => Type.isClassInstance(value, ClassA) || Type.isNull(value);
		const t1 = value => Type.isClassInstance(value, ClassB);
		const t2 = value => Type.isNumber(value) || Type.isNull(value);
		const t3 = value => Type.isString(value) || Type.isNull(value);
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(args.length === 2) {
			if(t0(args[0]) && t1(args[1])) {
				return foobar.__ks_0.call(that, args[0], args[1], void 0, void 0, void 0);
			}
			throw Helper.badArgs();
		}
		if(args.length >= 3 && args.length <= 5) {
			if(t0(args[0])) {
				if(t1(args[1])) {
					if(t2(args[2]) && Helper.isVarargs(args, 0, 1, t2, pts = [3], 0) && Helper.isVarargs(args, 0, 1, t2, pts, 1) && te(pts, 2)) {
						return foobar.__ks_0.call(that, args[0], args[1], args[2], Helper.getVararg(args, 3, pts[1]), Helper.getVararg(args, pts[1], pts[2]));
					}
					throw Helper.badArgs();
				}
				if(t3(args[1]) && t1(args[2]) && Helper.isVarargs(args, 0, 1, t2, pts = [3], 0) && Helper.isVarargs(args, 0, 1, t2, pts, 1) && te(pts, 2)) {
					return foobar.__ks_1.call(that, args[0], args[1], args[2], Helper.getVararg(args, 3, pts[1]), Helper.getVararg(args, pts[1], pts[2]), void 0);
				}
				throw Helper.badArgs();
			}
			throw Helper.badArgs();
		}
		if(args.length === 6) {
			if(t0(args[0]) && t3(args[1]) && t1(args[2]) && t2(args[3]) && t2(args[4]) && t2(args[5])) {
				return foobar.__ks_1.call(that, args[0], args[1], args[2], args[3], args[4], args[5]);
			}
		}
		throw Helper.badArgs();
	};
};