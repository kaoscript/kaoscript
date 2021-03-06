module.exports = function(expect) {
	let foo = (() => {
		return function() {
			if(arguments.length < 1) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
			}
			let __ks_i = -1;
			let items = Array.prototype.slice.call(arguments, __ks_i + 1, Math.min(arguments.length, __ks_i + 4));
			__ks_i += items.length;
			let __ks__;
			let x = arguments.length > 3 && (__ks__ = arguments[++__ks_i]) !== void 0 && __ks__ !== null ? __ks__ : 42;
			return [items, x];
		};
	})();
	expect(() => {
		return foo();
	}).to.throw();
	expect(foo(1)).to.eql([[1], 42]);
	expect(foo(1, 2)).to.eql([[1, 2], 42]);
	expect(foo(1, 2, 3)).to.eql([[1, 2, 3], 42]);
	expect(foo(1, 2, 3, 4)).to.eql([[1, 2, 3], 4]);
};