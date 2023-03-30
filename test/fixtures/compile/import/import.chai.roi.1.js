const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function(assert, Assertion, config, expect, should, Should, use) {
	var deepEql = require("deep-eql");
	use(Helper.function(function({Assertion}, {flag}) {
		function comparator() {
			return comparator.__ks_rt(this, arguments);
		};
		comparator.__ks_0 = function(a, b) {
			if(Type.isEnumInstance(a) === true) {
				if(Type.isEnumInstance(b) === true) {
					return (a.value === b.value) && (a.__ks_enum === b.__ks_enum);
				}
				else if(Type.isNumber(b)) {
					return a.value === b;
				}
				else {
					return false;
				}
			}
			else if(Type.isEnumInstance(b) === true) {
				if(Type.isEnumInstance(a) === true) {
					return (a.value === b.value) && (a.__ks_enum === b.__ks_enum);
				}
				else if(Type.isNumber(a)) {
					return a === b.value;
				}
				else {
					return false;
				}
			}
			else {
				return null;
			}
		};
		comparator.__ks_rt = function(that, args) {
			const t0 = Type.isValue;
			if(args.length === 2) {
				if(t0(args[0]) && t0(args[1])) {
					return comparator.__ks_0.call(that, args[0], args[1]);
				}
			}
			throw Helper.badArgs();
		};
		function assertEql() {
			return assertEql.__ks_rt(this, arguments);
		};
		assertEql.__ks_0 = function(obj, msg = null) {
			if(msg !== null) {
				flag(this, "message", msg);
			}
			this.assert(deepEql(obj, this._obj, (() => {
				const o = new OBJ();
				o.comparator = comparator;
				return o;
			})()), "expected #{this} to deeply equal #{exp}", "expected #{this} to not deeply equal #{exp}", obj, this._obj, true);
		};
		assertEql.__ks_rt = function(that, args) {
			const t0 = Type.isValue;
			if(args.length >= 1 && args.length <= 2) {
				if(t0(args[0])) {
					return assertEql.__ks_0.call(that, args[0], args[1]);
				}
			}
			throw Helper.badArgs();
		};
		Assertion.addMethod("eql", assertEql);
		Assertion.addMethod("eqls", assertEql);
	}, (fn, ...args) => {
		const t0 = value => Type.isDexObject(value, 1, 0, {Assertion: Type.isValue});
		const t1 = value => Type.isDexObject(value, 1, 0, {flag: Type.isValue});
		if(args.length === 2) {
			if(t0(args[0]) && t1(args[1])) {
				return fn.call(null, args[0], args[1]);
			}
		}
		throw Helper.badArgs();
	}));
	return {
		assert,
		Assertion,
		config,
		expect,
		should,
		Should,
		use
	};
};