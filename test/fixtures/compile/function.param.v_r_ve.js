module.exports = function(expect) {
	let foo = function(x) {
		if(arguments.length < 2) {
			throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 2)");
		}
		if(x === void 0 || x === null) {
			throw new TypeError("'x' is not nullable");
		}
		let __ks_i;
		let items = arguments.length > 2 ? Array.prototype.slice.call(arguments, 1, __ks_i = arguments.length - 1) : (__ks_i = 1, []);
		let y = arguments[__ks_i];
		if(y === void 0 || y === null) {
			throw new TypeError("'y' is not nullable");
		}
		return [x, items, y];
	};
	expect(function() {
		return foo();
	}).to.throw();
	expect(function() {
		return foo(1);
	}).to.throw();
	expect(foo(1, 2)).to.eql([1, [], 2]);
	expect(foo(1, 2, 3)).to.eql([1, [2], 3]);
	expect(foo(1, 2, 3, 4)).to.eql([1, [2, 3], 4]);
}