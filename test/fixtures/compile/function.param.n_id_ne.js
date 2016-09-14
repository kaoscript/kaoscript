module.exports = function(expect, Class, Type) {
	function foo(x = null, __ks_0 = null, z = null) {
		return [x, z];
	}
	expect(foo()).to.eql([null, null]);
	expect(foo(1)).to.eql([1, null]);
	expect(foo(1, 2)).to.eql([1, null]);
	expect(foo(1, 2, 3)).to.eql([1, 3]);
}