module.exports = function(expect, Helper, Type) {
	function foo(...items) {
		if(items.length < 1) {
			throw new Error("Wrong number of arguments");
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