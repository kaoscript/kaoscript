module.exports = function(expect) {
	let foo = (() => {
		return function() {
			if(arguments.length < 3) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 3)");
			}
			let __ks_i = -1;
			let items = Array.prototype.slice.call(arguments, ++__ks_i, __ks_i = arguments.length - 3);
			let x = arguments[__ks_i];
			if(x === void 0 || x === null) {
				throw new TypeError("'x' is not nullable");
			}
			let y = arguments[++__ks_i];
			if(y === void 0 || y === null) {
				throw new TypeError("'y' is not nullable");
			}
			let z = arguments[++__ks_i];
			if(z === void 0 || z === null) {
				throw new TypeError("'z' is not nullable");
			}
			return [items, x, y, z];
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
	expect(foo(1, 2, 3)).to.eql([[], 1, 2, 3]);
	expect(foo(1, 2, 3, 4)).to.eql([[1], 2, 3, 4]);
	expect(foo(1, 2, 3, 4, 5, 6)).to.eql([[1, 2, 3], 4, 5, 6]);
};