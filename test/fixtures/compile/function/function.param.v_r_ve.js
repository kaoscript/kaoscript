module.exports = function(expect) {
	let foo = (() => {
		return function(x) {
			if(arguments.length < 2) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 2)");
			}
			if(x === void 0 || x === null) {
				throw new TypeError("'x' is not nullable");
			}
			let __ks_i = 0;
			let items = Array.prototype.slice.call(arguments, ++__ks_i, __ks_i = arguments.length - 1);
			let y = arguments[__ks_i];
			if(y === void 0 || y === null) {
				throw new TypeError("'y' is not nullable");
			}
			return [x, items, y];
		};
	})();
	expect(() => {
		return foo();
	}).to.throw();
	expect(() => {
		return foo(1);
	}).to.throw();
	expect(foo(1, 2)).to.eql([1, [], 2]);
	expect(foo(1, 2, 3)).to.eql([1, [2], 3]);
	expect(foo(1, 2, 3, 4)).to.eql([1, [2, 3], 4]);
};