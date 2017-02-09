module.exports = function(expect) {
	function foo(x) {
		if(x === undefined || x === null) {
			throw new Error("Missing parameter 'x'");
		}
		return [x];
	}
	expect(function() {
		return foo();
	}).to.throw();
	expect(foo(1)).to.eql([1]);
	expect(function() {
		return foo(null);
	}).to.throw();
	expect(foo(1, 2)).to.eql([1]);
}