module.exports = function(expect) {
	let foo = (function() {
		return function(x, y, z) {
			if(arguments.length < 1) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(x === void 0 || x === null) {
				throw new TypeError("'x' is not nullable");
			}
			if(y === void 0 || y === null) {
				y = 42;
			}
			if(z === void 0 || z === null) {
				z = 24;
			}
			return [x, y, z];
		};
	})();
	expect(function() {
		return foo();
	}).to.throw();
	expect(foo(1)).to.eql([1, 42, 24]);
	expect(foo(1, 2)).to.eql([1, 2, 24]);
	expect(foo(1, 2, 3, 4)).to.eql([1, 2, 3]);
};