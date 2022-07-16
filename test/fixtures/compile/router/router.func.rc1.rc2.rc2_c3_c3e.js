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
	class ClassB extends ClassA {
		static __ks_new_0() {
			const o = Object.create(ClassB.prototype);
			o.__ks_init();
			return o;
		}
		__ks_cons_rt(that, args) {
			super.__ks_cons_rt.call(null, that, args);
		}
	}
	class ClassC extends ClassA {
		static __ks_new_0() {
			const o = Object.create(ClassC.prototype);
			o.__ks_init();
			return o;
		}
		__ks_cons_rt(that, args) {
			super.__ks_cons_rt.call(null, that, args);
		}
	}
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(args) {
		return 0;
	};
	foobar.__ks_1 = function(args) {
		return 1;
	};
	foobar.__ks_2 = function(args, x, y) {
		return 2;
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = value => Type.isClassInstance(value, ClassB);
		const t1 = value => Type.isClassInstance(value, ClassA);
		const t2 = value => Type.isClassInstance(value, ClassC);
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(args.length === 0) {
			return foobar.__ks_0.call(that, []);
		}
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_1.call(that, [args[0]]);
			}
			if(t1(args[0])) {
				return foobar.__ks_0.call(that, [args[0]]);
			}
			throw Helper.badArgs();
		}
		if(Helper.isVarargs(args, 0, args.length - 2, t0, pts = [0], 0)) {
			if(Helper.isVarargs(args, 2, 2, t0, pts, 1) && te(pts, 2)) {
				return foobar.__ks_1.call(that, Helper.getVarargs(args, 0, pts[2]));
			}
			if(Helper.isVarargs(args, 1, 1, t2, pts, 1) && Helper.isVarargs(args, 1, 1, t2, pts, 2) && te(pts, 3)) {
				return foobar.__ks_2.call(that, Helper.getVarargs(args, 0, pts[1]), Helper.getVararg(args, pts[1], pts[2]), Helper.getVararg(args, pts[2], pts[3]));
			}
		}
		if(Helper.isVarargs(args, 2, args.length, t1, pts = [0], 0) && te(pts, 1)) {
			return foobar.__ks_0.call(that, Helper.getVarargs(args, 0, pts[1]));
		}
		throw Helper.badArgs();
	};
};