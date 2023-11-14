const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const __ksType = {
		isNamed: (value, mapper) => Type.isDexObject(value, 1, 0, {name: mapper[0], age: Type.isNumber})
	};
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
		__ks_func_foobar_0(name, age) {
			return (() => {
				const o = new OBJ();
				o.name = name;
				o.age = age;
				return o;
			})();
		}
		__ks_func_foobar_rt(that, proto, args) {
			const t0 = Type.isValue;
			const t1 = Type.isNumber;
			if(args.length === 2) {
				if(t0(args[0]) && t1(args[1])) {
					return proto.__ks_func_foobar_0.call(that, args[0], args[1]);
				}
			}
			throw Helper.badArgs();
		}
		quxbaz() {
			return this.__ks_func_quxbaz_rt.call(null, this, this, arguments);
		}
		__ks_func_quxbaz_0(name, age) {
			return this.foobar(name, age);
		}
		__ks_func_quxbaz_rt(that, proto, args) {
			const t0 = Type.isString;
			const t1 = Type.isValue;
			if(args.length === 2) {
				if(t0(args[0]) && t1(args[1])) {
					return proto.__ks_func_quxbaz_0.call(that, args[0], args[1]);
				}
			}
			throw Helper.badArgs();
		}
	}
};