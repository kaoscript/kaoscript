module.exports = function(expect) {
	let foo = (function() {
		return function() {
			if(arguments.length < 1) {
				throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
			}
			let __ks_i = -1;
			let items = Array.prototype.slice.call(arguments, __ks_i + 1, Math.min(arguments.length, __ks_i + 4));
			__ks_i += items.length;
			let values = arguments.length > ++__ks_i ? Array.prototype.slice.call(arguments, __ks_i, __ks_i = arguments.length) : [];
			return [items, values];
		};
	})();
	expect(function() {
		return foo();
	}).to.throw();
	expect(foo(1)).to.eql([[1], []]);
	expect(foo(1, 2)).to.eql([[1, 2], []]);
	expect(foo(1, 2, 3)).to.eql([[1, 2, 3], []]);
	expect(foo(1, 2, 3, 4)).to.eql([[1, 2, 3], [4]]);
	expect(foo(1, 2, 3, 4, 5)).to.eql([[1, 2, 3], [4, 5]]);
	expect(foo(1, 2, 3, 4, 5, 6)).to.eql([[1, 2, 3], [4, 5, 6]]);
	expect(foo(1, 2, 3, 4, 5, 6, 7)).to.eql([[1, 2, 3], [4, 5, 6, 7]]);
};