const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	class SuperClass {
		static __ks_new_0() {
			const o = Object.create(SuperClass.prototype);
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
	class SubClassA extends SuperClass {
		static __ks_new_0() {
			const o = Object.create(SubClassA.prototype);
			o.__ks_init();
			return o;
		}
		__ks_cons_rt(that, args) {
			super.__ks_cons_rt.call(null, that, args);
		}
	}
	class SubClassB extends SuperClass {
		static __ks_new_0() {
			const o = Object.create(SubClassB.prototype);
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
	foobar.__ks_0 = function(x) {
		return "sub";
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = value => Type.isClassInstance(value, SubClassA);
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
	quxbaz.__ks_0 = function(x) {
		return "super";
	};
	quxbaz.__ks_rt = function(that, args) {
		const t0 = value => Type.isClassInstance(value, SuperClass);
		if(args.length === 1) {
			if(t0(args[0])) {
				return quxbaz.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	const o = SubClassA.__ks_new_0();
	foobar.__ks_0(o);
};