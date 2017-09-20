module.exports = function(expect) {
	let foo = function() {
		if(arguments.length < 1) {
			throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
		}
		let __ks_i;
		let items = arguments.length > 1 ? Array.prototype.slice.call(arguments, 0, __ks_i = arguments.length - 1) : (__ks_i = 0, []);
		let x = arguments[__ks_i];
		if(x === void 0 || x === null) {
			throw new TypeError("'x' is not nullable");
		}
		return [items, x];
	};
	expect(function() {
		return foo();
	}).to.throw();
	expect(foo(1)).to.eql([[], 1]);
	expect(foo(1, 2)).to.eql([[1], 2]);
	expect(foo(1, 2, 3, 4)).to.eql([[1, 2, 3], 4]);
};