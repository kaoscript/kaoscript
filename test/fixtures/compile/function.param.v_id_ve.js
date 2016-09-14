module.exports = function(expect, Class, Type) {
	function foo() {
		if(arguments.length < 2) {
			throw new Error("Wrong number of arguments");
		}
		let __ks_i = -1;
		var x = arguments[++__ks_i];
		if(arguments.length > 2) {
			++__ks_i;
		}
		var y = arguments[++__ks_i];
		return [x, y];
	}
	expect(function() {
		return foo();
	}).to.throw();
	expect(function() {
		return foo(1);
	}).to.throw();
	expect(foo(1, 2)).to.eql([1, 2]);
	expect(foo(1, 2, 3)).to.eql([1, 3]);
	expect(foo(1, null, 3)).to.eql([1, 3]);
}