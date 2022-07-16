const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	class Type {
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
		static __ks_sttc_import_0(data, references, domain, node) {
			return Type.__ks_sttc_import_2(null, data, references, domain, node);
		}
		static __ks_sttc_import_1(name, data, references, node) {
			return Type.__ks_sttc_import_2(name, data, references, node.scope().domain(), node);
		}
		static __ks_sttc_import_2(name, data, references, domain, node) {
			if(name === void 0) {
				name = null;
			}
			return FoobarType.__ks_new_0();
		}
		static import() {
			const t0 = Type.isString;
			const t1 = Type.isValue;
			const t2 = Type.isDictionary;
			const t3 = value => Type.isClassInstance(value, AbstractNode);
			const t4 = value => Type.isClassInstance(value, Domain);
			const t5 = value => Type.isString(value) || Type.isNull(value);
			if(arguments.length === 4) {
				if(t0(arguments[0])) {
					if(t1(arguments[1]) && t2(arguments[2]) && t3(arguments[3])) {
						return Type.__ks_sttc_import_1(arguments[0], arguments[1], arguments[2], arguments[3]);
					}
				}
				if(t1(arguments[0]) && t2(arguments[1]) && t4(arguments[2]) && t3(arguments[3])) {
					return Type.__ks_sttc_import_0(arguments[0], arguments[1], arguments[2], arguments[3]);
				}
				throw Helper.badArgs();
			}
			if(arguments.length === 5) {
				if(t5(arguments[0]) && t1(arguments[1]) && t1(arguments[2]) && t4(arguments[3]) && t3(arguments[4])) {
					return Type.__ks_sttc_import_2(arguments[0], arguments[1], arguments[2], arguments[3], arguments[4]);
				}
			}
			throw Helper.badArgs();
		}
	}
	class FoobarType extends Type {
		static __ks_new_0() {
			const o = Object.create(FoobarType.prototype);
			o.__ks_init();
			return o;
		}
		__ks_cons_rt(that, args) {
			super.__ks_cons_rt.call(null, that, args);
		}
	}
};