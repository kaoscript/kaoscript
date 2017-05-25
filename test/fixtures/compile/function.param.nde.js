module.exports = function(expect) {
	let foo = function(x = null) {
		return [x];
	};
	expect(foo()).to.eql([null]);
	expect(foo(1)).to.eql([1]);
}