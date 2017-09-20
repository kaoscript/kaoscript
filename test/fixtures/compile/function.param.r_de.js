module.exports = function(expect) {
	let foo = function(...items) {
		let x = 42;
		return [items, x];
	};
	expect(foo()).to.eql([[], 42]);
	expect(foo(1)).to.eql([[1], 42]);
	expect(foo(1, 2)).to.eql([[1, 2], 42]);
	expect(foo(1, 2, 3, 4)).to.eql([[1, 2, 3, 4], 42]);
};