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
	foobar.__ks_0 = function(a) {
		quxbaz(a, 0);
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = value => Type.isClassInstance(value, ClassA) || Type.isClassInstance(value, ClassB);
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	function quxbaz() {
		return quxbaz.__ks_rt(this, arguments);
	};
	quxbaz.__ks_0 = function(a, y) {
	};
	quxbaz.__ks_1 = function(x, y) {
	};
	quxbaz.__ks_2 = function(x, y) {
	};
	quxbaz.__ks_rt = function(that, args) {
		const t0 = value => Type.isClassInstance(value, ClassA);
		const t1 = Type.isNumber;
		const t2 = Type.isString;
		const t3 = value => Type.isClassInstance(value, ClassB);
		if(args.length === 2) {
			if(t0(args[0])) {
				if(t1(args[1])) {
					return quxbaz.__ks_1.call(that, args[0], args[1]);
				}
				if(t2(args[1])) {
					return quxbaz.__ks_0.call(that, args[0], args[1]);
				}
				throw Helper.badArgs();
			}
			if(t3(args[0])) {
				if(t1(args[1])) {
					return quxbaz.__ks_2.call(that, args[0], args[1]);
				}
				if(t2(args[1])) {
					return quxbaz.__ks_0.call(that, args[0], args[1]);
				}
				throw Helper.badArgs();
			}
		}
		throw Helper.badArgs();
	};
};