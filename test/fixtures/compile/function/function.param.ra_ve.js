module.exports = function(expect) {
	let foo = (() => {
		return function() {
			if(arguments.length < 2) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 2)");
			}
			let __ks_i = -1;
			let items = Array.prototype.slice.call(arguments, __ks_i + 1, Math.min(arguments.length - 1, __ks_i + 4));
			__ks_i += items.length;
			let x = arguments[++__ks_i];
			if(x === void 0 || x === null) {
				throw new TypeError("'x' is not nullable");
			}
			return [items, x];
		};
	})();
	expect(() => {
		return foo();
	}).to.throw();
	expect(() => {
		return foo(1);
	}).to.throw();
	expect(foo(1, 2)).to.eql([[1], 2]);
	expect(foo(1, 2, 3)).to.eql([[1, 2], 3]);
	expect(foo(1, 2, 3, 4)).to.eql([[1, 2, 3], 4]);
};