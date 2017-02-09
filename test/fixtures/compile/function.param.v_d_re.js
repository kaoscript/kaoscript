module.exports = function(expect) {
	function foo(x, y, ...items) {
		if(x === undefined || x === null) {
			throw new Error("Missing parameter 'x'");
		}
		if(y === undefined || y === null) {
			y = 42;
		}
		return [x, y, items];
	}
	expect(function() {
		return foo();
	}).to.throw();
	expect(foo(1)).to.eql([1, 42, []]);
	expect(foo(1, 2)).to.eql([1, 2, []]);
	expect(foo(1, 2, 3, 4)).to.eql([1, 2, [3, 4]]);
}