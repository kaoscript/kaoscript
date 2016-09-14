module.exports = function(expect, Class, Type) {
	function foo(x) {
		if(x === undefined || x === null) {
			throw new Error("Missing parameter 'x'");
		}
		if(!Type.isNumber(x)) {
			throw new Error("Invalid type for parameter 'x'");
		}
		return [x];
	}
	expect(function() {
		return foo();
	}).to.throw();
	expect(foo(1)).to.eql([1]);
	expect(function() {
		return foo("foo");
	}).to.throw();
	expect(foo(1, 2)).to.eql([1]);
	expect(function() {
		return foo("foo", 1);
	}).to.throw();
}