module.exports = function(expect) {
	let foo = (() => {
		return function(x, ...items) {
			if(arguments.length < 1) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(x === void 0 || x === null) {
				throw new TypeError("'x' is not nullable");
			}
			let y = 42;
			return [x, items, y];
		};
	})();
	expect(() => {
		return foo();
	}).to.throw();
	expect(foo(1)).to.eql([1, [], 42]);
	expect(foo(1, 2)).to.eql([1, [2], 42]);
	expect(foo(1, 2, 3, 4)).to.eql([1, [2, 3, 4], 42]);
};