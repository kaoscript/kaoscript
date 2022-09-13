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
		foobar() {
			return this.__ks_func_foobar_rt.call(null, this, this, arguments);
		}
		__ks_func_foobar_0() {
			return 0;
		}
		__ks_func_foobar_rt(that, proto, args) {
			if(args.length === 0) {
				return proto.__ks_func_foobar_0.call(that);
			}
			throw Helper.badArgs();
		}
	}
	class ClassB extends ClassA {
		static __ks_new_0() {
			const o = Object.create(ClassB.prototype);
			o.__ks_init();
			return o;
		}
		__ks_init() {
			super.__ks_init();
			this._element = ClassA.__ks_new_0();
		}
		__ks_cons_rt(that, args) {
			super.__ks_cons_rt.call(null, that, args);
		}
		foobar() {
			return this._element.__ks_func_foobar_rt.call(null, this._element, this._element, arguments);
		}
		__ks_func_foobar_0() {
			return this._element.__ks_func_foobar_0(...arguments);
		}
		__ks_func_foobar_rt(that, proto, args) {
			return proto.foobar.apply(that, args);
		}
	}
	const a = ClassA.__ks_new_0();
	const b = ClassB.__ks_new_0();
	a.__ks_func_foobar_0();
	b._element.__ks_func_foobar_0();
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(a) {
		a.__ks_func_foobar_0();
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = value => Type.isClassInstance(value, ClassA);
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};