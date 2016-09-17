module.exports = function(expect, Helper, Type) {
	function foo() {
		if(arguments.length < 1) {
			throw new Error("Wrong number of arguments");
		}
		let __ks_i = -1;
		let items = arguments.length > __ks_i + 2 ? Array.prototype.slice.call(arguments, __ks_i + 1, arguments.length - 1) : [];
		__ks_i += items.length;
		let values = Array.prototype.slice.call(arguments, __ks_i + 1, __ks_i + 2);
		return [items, values];
	}
	expect(function() {
		return foo();
	}).to.throw();
	expect(foo(1)).to.eql([[], [1]]);
	expect(foo(1, 2)).to.eql([[1], [2]]);
	expect(foo(1, 2, 3)).to.eql([[1, 2], [3]]);
	expect(foo(1, 2, 3, 4)).to.eql([[1, 2, 3], [4]]);
	expect(foo(1, 2, 3, 4, 5)).to.eql([[1, 2, 3, 4], [5]]);
	expect(foo(1, 2, 3, 4, 5, 6)).to.eql([[1, 2, 3, 4, 5], [6]]);
	expect(foo(1, 2, 3, 4, 5, 6, 7)).to.eql([[1, 2, 3, 4, 5, 6], [7]]);
}