module.exports = function(expect) {
	let foo = (function() {
		return function() {
			if(arguments.length < 1) {
				throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
			}
			let __ks_i;
			let items = arguments.length > 1 ? Array.prototype.slice.call(arguments, 0, __ks_i = arguments.length - 1) : (__ks_i = 0, []);
			let x = 42;
			let y = arguments[__ks_i];
			if(y === void 0 || y === null) {
				throw new TypeError("'y' is not nullable");
			}
			return [items, x, y];
		};
	})();
	expect(function() {
		return foo();
	}).to.throw();
	expect(foo(1)).to.eql([[], 42, 1]);
	expect(foo(1, 2)).to.eql([[1], 42, 2]);
	expect(foo(1, 2, 3, 4)).to.eql([[1, 2, 3], 42, 4]);
};