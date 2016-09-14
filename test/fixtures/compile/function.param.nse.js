module.exports = function(expect, Class, Type) {
	function foo(x = null) {
		return [x];
	}
	expect(foo()).to.eql([null]);
	expect(foo(1)).to.eql([1]);
}