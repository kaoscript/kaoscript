const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	class Foobar {
		static __ks_new_0() {
			const o = Object.create(Foobar.prototype);
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
		foobar() {
			return this.__ks_func_foobar_rt.call(null, this, this, arguments);
		}
		__ks_func_foobar_0(x) {
		}
		__ks_func_foobar_rt(that, proto, args) {
			const t0 = value => Type.isClassInstance(value, Foobar);
			if(args.length === 1) {
				if(t0(args[0])) {
					return proto.__ks_func_foobar_0.call(that, args[0]);
				}
			}
			throw Helper.badArgs();
		}
	}
	class Foobar2 {
		static __ks_new_0() {
			const o = Object.create(Foobar2.prototype);
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
		foobar() {
			return this.__ks_func_foobar_rt.call(null, this, this, arguments);
		}
		__ks_func_foobar_0() {
		}
		__ks_func_foobar_1(x) {
		}
		__ks_func_foobar_rt(that, proto, args) {
			const t0 = value => Type.isClassInstance(value, Foobar);
			if(args.length === 0) {
				return proto.__ks_func_foobar_0.call(that);
			}
			if(args.length === 1) {
				if(t0(args[0])) {
					return proto.__ks_func_foobar_1.call(that, args[0]);
				}
			}
			throw Helper.badArgs();
		}
	}
	function quxbaz() {
		return quxbaz.__ks_rt(this, arguments);
	};
	quxbaz.__ks_0 = function() {
		return Foobar.__ks_new_0();
	};
	quxbaz.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return quxbaz.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
	function waldo() {
		return waldo.__ks_rt(this, arguments);
	};
	waldo.__ks_0 = function(x) {
		let __ks_0;
		Type.isClassInstance(__ks_0 = quxbaz.__ks_0(), Foobar) ? __ks_0.__ks_func_foobar_0(x) : __ks_0.__ks_func_foobar_1(x);
	};
	waldo.__ks_rt = function(that, args) {
		const t0 = value => Type.isClassInstance(value, Foobar);
		if(args.length === 1) {
			if(t0(args[0])) {
				return waldo.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};