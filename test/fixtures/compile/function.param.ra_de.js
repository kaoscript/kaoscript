module.exports = function(expect, Class, Type) {
	function foo() {
		if(arguments.length < 1) {
			throw new Error("Wrong number of arguments");
		}
		let __ks_i = -1;
		let items = Array.prototype.slice.call(arguments, __ks_i + 1, Math.min(arguments.length, __ks_i + 4));
		__ks_i += items.length;
		if(arguments.length > 3) {
			var x = arguments[++__ks_i];
		}
		else  {
			var x = 42;
		}
		return [items, x];
	}
	expect(function() {
		return foo();
	}).to.throw();
	expect(foo(1)).to.eql([[1], 42]);
	expect(foo(1, 2)).to.eql([[1, 2], 42]);
	expect(foo(1, 2, 3)).to.eql([[1, 2, 3], 42]);
	expect(foo(1, 2, 3, 4)).to.eql([[1, 2, 3], 4]);
}