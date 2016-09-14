module.exports = function(expect, Class, Type) {
	function foo(x, __ks_0, y) {
		if(x === undefined || x === null) {
			throw new Error("Missing parameter 'x'");
		}
		if(y === undefined || y === null) {
			throw new Error("Missing parameter 'y'");
		}
		return [x, y];
	}
	expect(function() {
		return foo();
	}).to.throw();
	expect(function() {
		return foo(1);
	}).to.throw();
	expect(function() {
		return foo(1, 2);
	}).to.throw();
	expect(foo(1, 2, 3)).to.eql([1, 3]);
	expect(foo(1, null, 3)).to.eql([1, 3]);
}