module.exports = function(expect, Helper, Type) {
	function foo(x, ...items) {
		if(x === undefined || x === null) {
			throw new Error("Missing parameter 'x'");
		}
		return [x, items];
	}
	expect(function() {
		return foo();
	}).to.throw();
	expect(foo(1)).to.eql([1, []]);
	expect(foo(1, 2)).to.eql([1, [2]]);
	expect(foo(1, 2, 3, 4)).to.eql([1, [2, 3, 4]]);
}