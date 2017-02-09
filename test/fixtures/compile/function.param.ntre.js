module.exports = function(expect) {
	function foo(x) {
		if(x === undefined) {
			throw new Error("Missing parameter 'x'");
		}
		return [x];
	}
	expect(function() {
		return foo();
	}).to.throw();
	expect(foo(1)).to.eql([1]);
}