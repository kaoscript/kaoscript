module.exports = function(expect) {
	let foo = function() {
		let __ks_i = -1;
		let __ks__;
		let x = arguments.length > 0 && (__ks__ = arguments[++__ks_i]) !== void 0 && __ks__ !== null ? __ks__ : 42;
		let items = arguments.length > ++__ks_i ? Array.prototype.slice.call(arguments, __ks_i, __ks_i = arguments.length) : [];
		return [x, items];
	};
	expect(foo(42)).to.eql([42, []]);
	expect(foo(1)).to.eql([1, []]);
	expect(foo(1, 2)).to.eql([1, [2]]);
	expect(foo(1, 2, 3, 4)).to.eql([1, [2, 3, 4]]);
};