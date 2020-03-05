var Type = require("@kaoscript/runtime").Type;
module.exports = function(expect) {
	let foo = (() => {
		return function(x, y) {
			if(arguments.length < 2) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 2)");
			}
			if(x === void 0 || x === null) {
				throw new TypeError("'x' is not nullable");
			}
			else if(!Type.isString(x)) {
				throw new TypeError("'x' is not of type 'String'");
			}
			if(y === void 0 || y === null) {
				y = "foobar";
			}
			else if(!Type.isString(y)) {
				throw new TypeError("'y' is not of type 'String'");
			}
			return [x, y];
		};
	})();
	expect(() => {
		return foo();
	}).to.throw();
	expect(() => {
		return foo("foo");
	}).to.throw();
	expect(() => {
		return foo(true);
	}).to.throw();
	expect(() => {
		return foo(42);
	}).to.throw();
	expect(foo("foo", "bar")).to.eql(["foo", "bar"]);
	expect(foo("foo", null)).to.eql(["foo", "foobar"]);
	expect(() => {
		return foo("foo", true);
	}).to.throw();
};