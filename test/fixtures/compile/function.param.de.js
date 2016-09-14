module.exports = function(expect, Class, Type) {
	function foo(x) {
		if(x === undefined || x === null) {
			x = 42;
		}
		return [x];
	}
	expect(foo()).to.eql([42]);
	expect(foo(1)).to.eql([1]);
}