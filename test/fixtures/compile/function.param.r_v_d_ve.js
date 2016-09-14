module.exports = function(expect, Class, Type) {
	function foo() {
		if(arguments.length < 2) {
			throw new Error("Wrong number of arguments");
		}
		let __ks_i;
		let items = arguments.length > 2 ? Array.prototype.slice.call(arguments, 0, __ks_i = arguments.length - 2) : (__ks_i = 0, []);
		var x = arguments[__ks_i];
		var y = 42;
		var z = arguments[++__ks_i];
		return [items, x, y, z];
	}
	expect(function() {
		return foo();
	}).to.throw();
	expect(function() {
		return foo(1);
	}).to.throw();
	expect(foo(1, 2)).to.eql([[], 1, 42, 2]);
	expect(foo(1, 2, 3)).to.eql([[1], 2, 42, 3]);
	expect(foo(1, 2, 3, 4)).to.eql([[1, 2], 3, 42, 4]);
	expect(foo(1, 2, 3, 4, 5, 6)).to.eql([[1, 2, 3, 4], 5, 42, 6]);
}