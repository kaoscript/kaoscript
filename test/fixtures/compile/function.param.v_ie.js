module.exports = function(expect, Class, Type) {
	function foo(x, __ks_0) {
		if(x === undefined || x === null) {
			throw new Error("Missing parameter 'x'");
		}
		return [x];
	}
	expect(function() {
		return foo();
	}).to.throw();
	expect(foo(1)).to.eql([1]);
	expect(foo(1, 2)).to.eql([1]);
}