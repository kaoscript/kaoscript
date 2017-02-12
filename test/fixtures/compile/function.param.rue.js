module.exports = function(expect) {
	function foo(...items) {
		if(items.length < 1) {
			throw new SyntaxError("wrong number of rest values (" + items.length + " for at least 1)");
		}
		return [items];
	}
	expect(function() {
		return foo();
	}).to.throw();
	expect(foo(1)).to.eql([[1]]);
	expect(foo(1, 2)).to.eql([[1, 2]]);
	expect(foo(1, 2, 3)).to.eql([[1, 2, 3]]);
	expect(foo(1, 2, 3, 4)).to.eql([[1, 2, 3, 4]]);
}