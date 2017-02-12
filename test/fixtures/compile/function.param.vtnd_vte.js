var Type = require("@kaoscript/runtime").Type;
module.exports = function(expect) {
	function foo() {
		if(arguments.length < 1) {
			throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
		}
		let __ks_i = -1;
		let x;
		if(arguments.length > 1 && (x = arguments[++__ks_i]) !== void 0) {
			if(x !== null && !Type.isNumber(x)) {
				throw new TypeError("'x' is not of type 'Number'");
			}
		}
		else {
			x = null;
		}
		let y = arguments[++__ks_i];
		if(y === void 0 || y === null) {
			throw new TypeError("'y' is not nullable");
		}
		else if(!Type.isString(y)) {
			throw new TypeError("'y' is not of type 'String'");
		}
		return [x, y];
	}
	expect(function() {
		return foo();
	}).to.throw();
	expect(function() {
		return foo(1);
	}).to.throw();
	expect(foo("foo")).to.eql([null, "foo"]);
	expect(foo(1, "foo")).to.eql([1, "foo"]);
	expect(function() {
		return foo("foo", "bar");
	}).to.throw();
}