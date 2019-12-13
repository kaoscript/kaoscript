var {Dictionary, Helper, Operator, Type} = require("@kaoscript/runtime");
module.exports = function(expect) {
	let Foobar = Helper.enum(Number, {
		foo: 1,
		bar: 2,
		qux: 4
	});
	function foobar() {
		if(arguments.length === 1 && Type.isEnumInstance(arguments[0], Foobar)) {
			let __ks_i = -1;
			let x = arguments[++__ks_i];
			if(x === void 0 || x === null) {
				throw new TypeError("'x' is not nullable");
			}
			else if(!Type.isEnumInstance(x, Foobar)) {
				throw new TypeError("'x' is not of type 'Foobar'");
			}
			return "enum";
		}
		else if(arguments.length === 1 && Type.isNumber(arguments[0])) {
			let __ks_i = -1;
			let x = arguments[++__ks_i];
			if(x === void 0 || x === null) {
				throw new TypeError("'x' is not nullable");
			}
			else if(!Type.isNumber(x)) {
				throw new TypeError("'x' is not of type 'Number'");
			}
			return "number";
		}
		else if(arguments.length === 1) {
			let __ks_i = -1;
			let x = arguments[++__ks_i];
			if(x === void 0 || x === null) {
				throw new TypeError("'x' is not nullable");
			}
			else if(!Type.isDictionary(x)) {
				throw new TypeError("'x' is not of type 'Dictionary'");
			}
			return "dictionary";
		}
		else {
			throw new SyntaxError("Wrong number of arguments");
		}
	};
	expect(foobar(Foobar.foo)).to.equal("enum");
	expect(foobar(Foobar(Foobar.foo | Foobar.bar))).to.equal("enum");
	expect(foobar(0)).to.equal("number");
	expect(foobar(new Dictionary())).to.equal("dictionary");
	function testIf(x, y, z) {
		if(arguments.length < 3) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 3)");
		}
		if(x === void 0 || x === null) {
			throw new TypeError("'x' is not nullable");
		}
		else if(!Type.isEnumInstance(x, Foobar)) {
			throw new TypeError("'x' is not of type 'Foobar'");
		}
		if(y === void 0 || y === null) {
			throw new TypeError("'y' is not nullable");
		}
		else if(!Type.isNumber(y)) {
			throw new TypeError("'y' is not of type 'Number'");
		}
		if(z === void 0 || z === null) {
			throw new TypeError("'z' is not nullable");
		}
		const results = [];
		if((x & Foobar.foo) !== 0) {
			results.push("c");
		}
		else {
			results.push(null);
		}
		if((y & Foobar.foo) !== 0) {
			results.push("c");
		}
		else {
			results.push(null);
		}
		if(Operator.bitwiseAnd(z, Foobar.foo) !== 0) {
			results.push("c");
		}
		else {
			results.push(null);
		}
		results.push(((x & Foobar.foo) !== 0) ? "c" : null);
		results.push(((y & Foobar.foo) !== 0) ? "c" : null);
		results.push((Operator.bitwiseAnd(z, Foobar.foo) !== 0) ? "c" : null);
		return results;
	}
	expect(testIf(Foobar(Foobar.foo | Foobar.bar), Foobar(Foobar.foo | Foobar.bar).value, Foobar(Foobar.foo | Foobar.bar))).to.eql(["c", "c", "c", "c", "c", "c"]);
	expect(testIf(Foobar.bar, Foobar.foo.value | Foobar.bar.value, Foobar.foo.value | Foobar.bar.value)).to.eql([null, "c", "c", null, "c", "c"]);
};