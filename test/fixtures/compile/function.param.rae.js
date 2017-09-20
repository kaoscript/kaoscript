module.exports = function(expect) {
	let foo = function() {
		let __ks_i = -1;
		let items = Array.prototype.slice.call(arguments, __ks_i + 1, Math.min(arguments.length, __ks_i + 4));
		return [items];
	};
	expect(foo()).to.eql([[]]);
	expect(foo(1)).to.eql([[1]]);
	expect(foo(1, 2)).to.eql([[1, 2]]);
	expect(foo(1, 2, 3)).to.eql([[1, 2, 3]]);
	expect(foo(1, 2, 3, 4)).to.eql([[1, 2, 3]]);
};