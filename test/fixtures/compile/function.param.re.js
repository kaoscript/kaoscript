module.exports = function(expect) {
	function foo(...items) {
		return [items];
	}
	expect(foo()).to.eql([[]]);
	expect(foo(1)).to.eql([[1]]);
	expect(foo(1, 2)).to.eql([[1, 2]]);
	expect(foo(1, 2, 3, 4)).to.eql([[1, 2, 3, 4]]);
}