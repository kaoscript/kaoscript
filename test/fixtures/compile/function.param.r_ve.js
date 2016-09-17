module.exports = function(expect, Helper, Type) {
	function foo() {
		if(arguments.length < 1) {
			throw new Error("Wrong number of arguments");
		}
		let __ks_i;
		let items = arguments.length > 1 ? Array.prototype.slice.call(arguments, 0, __ks_i = arguments.length - 1) : (__ks_i = 0, []);
		var x = arguments[__ks_i];
		return [items, x];
	}
	expect(function() {
		return foo();
	}).to.throw();
	expect(foo(1)).to.eql([[], 1]);
	expect(foo(1, 2)).to.eql([[1], 2]);
	expect(foo(1, 2, 3, 4)).to.eql([[1, 2, 3], 4]);
}