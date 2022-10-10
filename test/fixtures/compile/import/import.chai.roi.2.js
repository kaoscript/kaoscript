const {Dictionary, Helper, Type} = require("@kaoscript/runtime");
module.exports = function(assert, Assertion, config, expect, should, Should, use) {
	var __ks_0_valuable = Type.isValue(assert);
	var __ks_1_valuable = Type.isValue(Assertion);
	var __ks_2_valuable = Type.isValue(config);
	var __ks_3_valuable = Type.isValue(expect);
	var __ks_4_valuable = Type.isValue(should);
	var __ks_5_valuable = Type.isValue(Should);
	var __ks_6_valuable = Type.isValue(use);
	if(!__ks_0_valuable || !__ks_1_valuable || !__ks_2_valuable || !__ks_3_valuable || !__ks_4_valuable || !__ks_5_valuable || !__ks_6_valuable) {
		var __ks__ = require("chai");
		if(!__ks_0_valuable) {
			assert = __ks__.assert;
		}
		if(!__ks_1_valuable) {
			Assertion = __ks__.Assertion;
		}
		if(!__ks_2_valuable) {
			config = __ks__.config;
		}
		if(!__ks_3_valuable) {
			expect = __ks__.expect;
		}
		if(!__ks_4_valuable) {
			should = __ks__.should;
		}
		if(!__ks_5_valuable) {
			Should = __ks__.Should;
		}
		if(!__ks_6_valuable) {
			use = __ks__.use;
		}
	}
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
				const d = new Dictionary();
				d.comparator = comparator;
				return d;
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
		const t0 = Type.isDestructurableObject;
		if(args.length === 2) {
			if(t0(args[0]) && t0(args[1])) {
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