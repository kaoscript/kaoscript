module.exports = function(expect, Class, Type) {
	function foo(__ks_0, x) {
		if(x === undefined || x === null) {
			throw new Error("Missing parameter 'x'");
		}
		return [x];
	}
	expect(function() {
		return foo();
	}).to.throw();
	expect(function() {
		return foo(1);
	}).to.throw();
	expect(foo(1, 2)).to.eql([2]);
}