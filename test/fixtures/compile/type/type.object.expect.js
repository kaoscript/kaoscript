const {Dictionary, Helper, Type} = require("@kaoscript/runtime");
module.exports = function(expect) {
	var JS = require("@kaoscript/test-import/src/external.js");
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
	const StructA = Helper.struct(function() {
		return new Dictionary;
	}, function(__ks_new, args) {
		if(args.length === 0) {
			return __ks_new();
		}
		throw Helper.badArgs();
	});
	const TupleA = Helper.tuple(function() {
		return [];
	}, function(__ks_new, args) {
		if(args.length === 0) {
			return __ks_new();
		}
		throw Helper.badArgs();
	});
	function id() {
		return id.__ks_rt(this, arguments);
	};
	id.__ks_0 = function(x) {
		if(x === void 0) {
			x = null;
		}
		return x;
	};
	id.__ks_rt = function(that, args) {
		if(args.length === 1) {
			return id.__ks_0.call(that, args[0]);
		}
		throw Helper.badArgs();
	};
	function test() {
		return test.__ks_rt(this, arguments);
	};
	test.__ks_0 = function(x) {
		return "object";
	};
	test.__ks_1 = function(x) {
		if(x === void 0) {
			x = null;
		}
		return "any";
	};
	test.__ks_rt = function(that, args) {
		const t0 = Type.isObject;
		if(args.length === 1) {
			if(t0(args[0])) {
				return test.__ks_0.call(that, args[0]);
			}
			return test.__ks_1.call(that, args[0]);
		}
		throw Helper.badArgs();
	};
	expect(test.__ks_1(null)).to.equal("any", "null");
	expect(test(id.__ks_0(null))).to.equal("any", "id(null)");
	expect(test.__ks_1(true)).to.equal("any", "boolean");
	expect(test(id.__ks_0(true))).to.equal("any", "id(boolean)");
	expect(test.__ks_1(42)).to.equal("any", "number");
	expect(test(id.__ks_0(42))).to.equal("any", "id(number)");
	expect(test.__ks_1("foobar")).to.equal("any", "string");
	expect(test(id.__ks_0("foobar"))).to.equal("any", "id(string)");
	expect(test.__ks_0(/foobar/)).to.equal("object", "regex");
	expect(test(id.__ks_0(/foobar/))).to.equal("object", "id(regex)");
	expect(test.__ks_1([])).to.equal("any", "array");
	expect(test(id.__ks_0([]))).to.equal("any", "id(array)");
	expect(test.__ks_0(new Dictionary())).to.equal("object", "dict");
	expect(test(id.__ks_0(new Dictionary()))).to.equal("object", "id(dict)");
	expect(test.__ks_1(test)).to.equal("any", "func");
	expect(test(id.__ks_0(test))).to.equal("any", "id(func)");
	expect(test.__ks_1(ClassA)).to.equal("any", "class");
	expect(test(id.__ks_0(ClassA))).to.equal("any", "id(class)");
	expect(test.__ks_0(ClassA.__ks_new_0())).to.equal("object", "class-instance");
	expect(test(id.__ks_0(ClassA.__ks_new_0()))).to.equal("object", "id(class-instance)");
	expect(test.__ks_1(StructA)).to.equal("any", "struct");
	expect(test(id.__ks_0(StructA))).to.equal("any", "id(struct)");
	expect(test.__ks_0(StructA.__ks_new())).to.equal("object", "struct-instance");
	expect(test(id.__ks_0(StructA.__ks_new()))).to.equal("object", "id(struct-instance)");
	expect(test.__ks_1(TupleA)).to.equal("any", "tuple");
	expect(test(id.__ks_0(TupleA))).to.equal("any", "id(tuple)");
	expect(test.__ks_1(TupleA.__ks_new())).to.equal("any", "tuple-instance");
	expect(test(id.__ks_0(TupleA.__ks_new()))).to.equal("any", "id(tuple-instance)");
	expect(test(JS.object)).to.equal("object", "js(object)");
	expect(test(JS.ClassA)).to.equal("any", "js(class)");
	expect(test(new JS.ClassA())).to.equal("object", "class-instance(js)");
	expect(test(id.__ks_0(new JS.ClassA()))).to.equal("object", "id(class-instance(js))");
	expect(test(JS.instanceA)).to.equal("object", "js(class-instance)");
};