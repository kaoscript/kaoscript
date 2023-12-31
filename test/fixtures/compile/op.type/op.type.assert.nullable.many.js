const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function toArray() {
		return toArray.__ks_rt(this, arguments);
	};
	toArray.__ks_0 = function(x) {
		return Helper.assertArray(x, 1);
	};
	toArray.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		if(args.length === 1) {
			if(t0(args[0])) {
				return toArray.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	function toBoolean() {
		return toBoolean.__ks_rt(this, arguments);
	};
	toBoolean.__ks_0 = function(x) {
		return Helper.assertBoolean(x, 1);
	};
	toBoolean.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		if(args.length === 1) {
			if(t0(args[0])) {
				return toBoolean.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	function toClass() {
		return toClass.__ks_rt(this, arguments);
	};
	toClass.__ks_0 = function(x) {
		return Helper.assertClass(x, 1);
	};
	toClass.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		if(args.length === 1) {
			if(t0(args[0])) {
				return toClass.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	function toDictionary() {
		return toDictionary.__ks_rt(this, arguments);
	};
	toDictionary.__ks_0 = function(x) {
		return Helper.assertObject(x, 1);
	};
	toDictionary.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		if(args.length === 1) {
			if(t0(args[0])) {
				return toDictionary.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	function toEnum() {
		return toEnum.__ks_rt(this, arguments);
	};
	toEnum.__ks_0 = function(x) {
		return Helper.assertEnum(x, 1);
	};
	toEnum.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		if(args.length === 1) {
			if(t0(args[0])) {
				return toEnum.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	function toFunction() {
		return toFunction.__ks_rt(this, arguments);
	};
	toFunction.__ks_0 = function(x) {
		return Helper.assertFunction(x, 1);
	};
	toFunction.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		if(args.length === 1) {
			if(t0(args[0])) {
				return toFunction.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	function toNamespace() {
		return toNamespace.__ks_rt(this, arguments);
	};
	toNamespace.__ks_0 = function(x) {
		return Helper.assertNamespace(x, 1);
	};
	toNamespace.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		if(args.length === 1) {
			if(t0(args[0])) {
				return toNamespace.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	function toNumber() {
		return toNumber.__ks_rt(this, arguments);
	};
	toNumber.__ks_0 = function(x) {
		return Helper.assertNumber(x, 1);
	};
	toNumber.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		if(args.length === 1) {
			if(t0(args[0])) {
				return toNumber.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	function toObject() {
		return toObject.__ks_rt(this, arguments);
	};
	toObject.__ks_0 = function(x) {
		return Helper.assertObject(x, 1);
	};
	toObject.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		if(args.length === 1) {
			if(t0(args[0])) {
				return toObject.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	function toPrimitive() {
		return toPrimitive.__ks_rt(this, arguments);
	};
	toPrimitive.__ks_0 = function(x) {
		return Helper.assertPrimitive(x, 1);
	};
	toPrimitive.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		if(args.length === 1) {
			if(t0(args[0])) {
				return toPrimitive.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	function toRegExp() {
		return toRegExp.__ks_rt(this, arguments);
	};
	toRegExp.__ks_0 = function(x) {
		return Helper.assertRegExp(x, 1);
	};
	toRegExp.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		if(args.length === 1) {
			if(t0(args[0])) {
				return toRegExp.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	function toString() {
		return toString.__ks_rt(this, arguments);
	};
	toString.__ks_0 = function(x) {
		return Helper.assertString(x, 1);
	};
	toString.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		if(args.length === 1) {
			if(t0(args[0])) {
				return toString.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	function toStruct() {
		return toStruct.__ks_rt(this, arguments);
	};
	toStruct.__ks_0 = function(x) {
		return Helper.assertStruct(x, 1);
	};
	toStruct.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		if(args.length === 1) {
			if(t0(args[0])) {
				return toStruct.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
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
	}
	function toClassInstance() {
		return toClassInstance.__ks_rt(this, arguments);
	};
	toClassInstance.__ks_0 = function(x) {
		return Helper.assert(x, "\"Foobar\"", 1, value => Type.isClassInstance(value, Foobar));
	};
	toClassInstance.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		if(args.length === 1) {
			if(t0(args[0])) {
				return toClassInstance.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	const Quxbaz = Helper.enum(Number, 0);
	function toEnumInstance() {
		return toEnumInstance.__ks_rt(this, arguments);
	};
	toEnumInstance.__ks_0 = function(x) {
		return Helper.assert(x, "\"Quxbaz\"", 1, value => Type.isEnumInstance(value, Quxbaz));
	};
	toEnumInstance.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		if(args.length === 1) {
			if(t0(args[0])) {
				return toEnumInstance.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	const Corge = Helper.struct(function() {
		return new OBJ();
	}, function(__ks_new, args) {
		if(args.length === 0) {
			return __ks_new();
		}
		throw Helper.badArgs();
	}, function(__ks_new, item) {
		if(Type.isStructInstance(item, Corge)) {
			return item;
		}
		if(!Type.isObject(item)) {
			return null;
		}
		const args = [];
		let arg;
		return __ks_new.call(null, args);
	});
	function toStructInstance() {
		return toStructInstance.__ks_rt(this, arguments);
	};
	toStructInstance.__ks_0 = function(x) {
		return Helper.assert(x, "\"Corge\"", 1, value => Type.isStructInstance(value, Corge));
	};
	toStructInstance.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		if(args.length === 1) {
			if(t0(args[0])) {
				return toStructInstance.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};