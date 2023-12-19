const {Helper, OBJ, Operator, Type} = require("@kaoscript/runtime");
module.exports = function(expect) {
	const Foobar = Helper.bitmask(Number, ["foo", 1, "bar", 2, "qux", 4]);
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(x) {
		return "enum";
	};
	foobar.__ks_1 = function(x) {
		return "number";
	};
	foobar.__ks_2 = function(x) {
		return "dictionary";
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = value => Type.isBitmaskInstance(value, Foobar);
		const t1 = Type.isNumber;
		const t2 = Type.isObject;
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
			if(t1(args[0])) {
				return foobar.__ks_1.call(that, args[0]);
			}
			if(t2(args[0])) {
				return foobar.__ks_2.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	expect(foobar.__ks_0(Foobar.foo)).to.equal("enum");
	expect(foobar.__ks_0(Foobar(Foobar.foo | Foobar.bar))).to.equal("enum");
	expect(foobar.__ks_1(0)).to.equal("number");
	expect(foobar.__ks_2(new OBJ())).to.equal("dictionary");
	function testIf() {
		return testIf.__ks_rt(this, arguments);
	};
	testIf.__ks_0 = function(x, y, z) {
		const results = [];
		if((x & Foobar.foo) != 0) {
			results.push("c");
		}
		else {
			results.push(null);
		}
		if((Foobar(y) & Foobar.foo) != 0) {
			results.push("c");
		}
		else {
			results.push(null);
		}
		if((Foobar(z) & Foobar.foo) != 0) {
			results.push("c");
		}
		else {
			results.push(null);
		}
		results.push(((x & Foobar.foo) != 0) ? "c" : null);
		results.push(((y & Foobar.foo) != 0) ? "c" : null);
		results.push((Operator.bitAnd(z, Foobar.foo) != 0) ? "c" : null);
		return results;
	};
	testIf.__ks_rt = function(that, args) {
		const t0 = value => Type.isBitmaskInstance(value, Foobar);
		const t1 = Type.isNumber;
		const t2 = Type.isValue;
		if(args.length === 3) {
			if(t0(args[0]) && t1(args[1]) && t2(args[2])) {
				return testIf.__ks_0.call(that, args[0], args[1], args[2]);
			}
		}
		throw Helper.badArgs();
	};
	expect(testIf.__ks_0(Foobar(Foobar.foo | Foobar.bar), Foobar(Foobar.foo | Foobar.bar).value, Foobar(Foobar.foo | Foobar.bar))).to.eql(["c", "c", "c", "c", "c", "c"]);
	expect(testIf.__ks_0(Foobar.bar, Foobar.foo.value | Foobar.bar.value, Foobar.foo.value | Foobar.bar.value)).to.eql([null, "c", "c", null, "c", "c"]);
};