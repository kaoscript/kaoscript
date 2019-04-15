var Type = require("@kaoscript/runtime").Type;
module.exports = function(expect) {
	let foo = (function() {
		return function(x = null) {
			if(x !== null && !Type.isNumber(x)) {
				throw new TypeError("'x' is not of type 'Number'");
			}
			return [x];
		};
	})();
	expect(foo()).to.eql([null]);
	expect(foo(1)).to.eql([1]);
	expect(function() {
		return foo("foo");
	}).to.throw();
	expect(foo(1, 2)).to.eql([1]);
	expect(function() {
		return foo("foo", 1);
	}).to.throw();
};