module.exports = function(expect) {
	let foo = (() => {
		return function(x, __ks_0, y) {
			if(arguments.length < 3) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 3)");
			}
			if(x === void 0 || x === null) {
				throw new TypeError("'x' is not nullable");
			}
			if(y === void 0 || y === null) {
				throw new TypeError("'y' is not nullable");
			}
			return [x, y];
		};
	})();
	expect(() => {
		return foo();
	}).to.throw();
	expect(() => {
		return foo(1);
	}).to.throw();
	expect(() => {
		return foo(1, 2);
	}).to.throw();
	expect(foo(1, 2, 3)).to.eql([1, 3]);
	expect(foo(1, null, 3)).to.eql([1, 3]);
};