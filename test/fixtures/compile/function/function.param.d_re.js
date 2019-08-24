module.exports = function(expect) {
	let foo = function(x, ...items) {
		if(x === void 0 || x === null) {
			x = 42;
		}
		return [x, items];
	};
	expect(foo(42)).to.eql([42, []]);
	expect(foo(1)).to.eql([1, []]);
	expect(foo(1, 2)).to.eql([1, [2]]);
	expect(foo(1, 2, 3, 4)).to.eql([1, [2, 3, 4]]);
};