var Type = require("@kaoscript/runtime").Type;
module.exports = function(expect) {
	let foo = (() => {
		return function(x) {
			if(arguments.length < 1) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(x === void 0 || x === null) {
				throw new TypeError("'x' is not nullable");
			}
			else if(!Type.isNumber(x)) {
				throw new TypeError("'x' is not of type 'Number'");
			}
			return [x];
		};
	})();
	expect(() => {
		return foo();
	}).to.throw();
	expect(foo(1)).to.eql([1]);
	expect(() => {
		return foo("foo");
	}).to.throw();
	expect(foo(1, 2)).to.eql([1]);
	expect(() => {
		return foo("foo", 1);
	}).to.throw();
};