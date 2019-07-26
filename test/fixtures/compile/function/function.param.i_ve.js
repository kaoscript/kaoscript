module.exports = function(expect) {
	let foo = (function() {
		return function(__ks_0, x) {
			if(arguments.length < 2) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 2)");
			}
			if(x === void 0 || x === null) {
				throw new TypeError("'x' is not nullable");
			}
			return [x];
		};
	})();
	expect(function() {
		return foo();
	}).to.throw();
	expect(function() {
		return foo(1);
	}).to.throw();
	expect(foo(1, 2)).to.eql([2]);
};