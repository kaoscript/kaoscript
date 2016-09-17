module.exports = function(expect, Helper, Type) {
	function foo(x = null) {
		return [x];
	}
	expect(foo()).to.eql([null]);
	expect(foo(1)).to.eql([1]);
}