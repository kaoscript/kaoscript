module.exports = function(expect) {
	function foo(x, ...items) {
		if(x === undefined || x === null) {
			throw new Error("Missing parameter 'x'");
		}
		var y = 42;
		return [x, items, y];
	}
	expect(function() {
		return foo();
	}).to.throw();
	expect(foo(1)).to.eql([1, [], 42]);
	expect(foo(1, 2)).to.eql([1, [2], 42]);
	expect(foo(1, 2, 3, 4)).to.eql([1, [2, 3, 4], 42]);
}