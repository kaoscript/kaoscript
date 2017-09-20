module.exports = function(expect) {
	let foo = function(x, y, ...items) {
		if(arguments.length < 1) {
			throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(x === void 0 || x === null) {
			throw new TypeError("'x' is not nullable");
		}
		if(y === void 0 || y === null) {
			y = 42;
		}
		return [x, y, items];
	};
	expect(function() {
		return foo();
	}).to.throw();
	expect(foo(1)).to.eql([1, 42, []]);
	expect(foo(1, 2)).to.eql([1, 2, []]);
	expect(foo(1, 2, 3, 4)).to.eql([1, 2, [3, 4]]);
};