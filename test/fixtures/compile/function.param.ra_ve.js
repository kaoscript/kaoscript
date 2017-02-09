module.exports = function(expect) {
	function foo() {
		if(arguments.length < 2) {
			throw new Error("Wrong number of arguments");
		}
		let __ks_i = -1;
		let items = Array.prototype.slice.call(arguments, __ks_i + 1, Math.min(arguments.length - 1, __ks_i + 4));
		__ks_i += items.length;
		var x = arguments[++__ks_i];
		return [items, x];
	}
	expect(function() {
		return foo();
	}).to.throw();
	expect(function() {
		return foo(1);
	}).to.throw();
	expect(foo(1, 2)).to.eql([[1], 2]);
	expect(foo(1, 2, 3)).to.eql([[1, 2], 3]);
	expect(foo(1, 2, 3, 4)).to.eql([[1, 2, 3], 4]);
}