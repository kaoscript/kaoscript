module.exports = function(expect, Helper, Type) {
	function foo(x) {
		if(arguments.length < 2) {
			throw new Error("Wrong number of arguments");
		}
		if(x === undefined || x === null) {
			throw new Error("Missing parameter 'x'");
		}
		let __ks_i;
		let items = arguments.length > 2 ? Array.prototype.slice.call(arguments, 1, __ks_i = arguments.length - 1) : (__ks_i = 1, []);
		var y = arguments[__ks_i];
		return [x, items, y];
	}
	expect(function() {
		return foo();
	}).to.throw();
	expect(function() {
		return foo(1);
	}).to.throw();
	expect(foo(1, 2)).to.eql([1, [], 2]);
	expect(foo(1, 2, 3)).to.eql([1, [2], 3]);
	expect(foo(1, 2, 3, 4)).to.eql([1, [2, 3], 4]);
}