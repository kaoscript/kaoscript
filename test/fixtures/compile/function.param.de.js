module.exports = function(expect) {
	let foo = function(x) {
		if(x === void 0 || x === null) {
			x = 42;
		}
		return [x];
	};
	expect(foo()).to.eql([42]);
	expect(foo(1)).to.eql([1]);
}