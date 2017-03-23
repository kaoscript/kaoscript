module.exports = function(expect) {
	function foo(x) {
		if(arguments.length < 1) {
			throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(x === void 0) {
			x = null;
		}
		return [x];
	}
	expect(function() {
		return foo();
	}).to.throw();
	expect(foo(1)).to.eql([1]);
	expect(foo(null)).to.eql([null]);
	expect(foo(1, 2)).to.eql([1]);
}