module.exports = function(expect) {
	function foo() {
		let __ks_i = -1;
		if(arguments.length > 0) {
			var x = arguments[++__ks_i];
		}
		else {
			var x = 24;
		}
		let items = arguments.length > ++__ks_i ? Array.prototype.slice.call(arguments, __ks_i, __ks_i = arguments.length) : [];
		__ks_i += items.length;
		var y = 42;
		return [x, items, y];
	}
	expect(foo()).to.eql([24, [], 42]);
	expect(foo(1)).to.eql([1, [], 42]);
	expect(foo(1, 2)).to.eql([1, [2], 42]);
	expect(foo(1, 2, 3, 4)).to.eql([1, [2, 3, 4], 42]);
}