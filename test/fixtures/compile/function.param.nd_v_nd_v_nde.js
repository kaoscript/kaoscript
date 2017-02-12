module.exports = function(expect) {
	function foo() {
		if(arguments.length < 2) {
			throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 2)");
		}
		let __ks_i = -1;
		let __ks__;
		let u = arguments.length > 2 && (__ks__ = arguments[++__ks_i]) !== void 0 ? __ks__ : null;
		let v = arguments[++__ks_i];
		if(v === void 0 || v === null) {
			throw new TypeError("'v' is not nullable");
		}
		let x = arguments.length > 3 && (__ks__ = arguments[++__ks_i]) !== void 0 ? __ks__ : null;
		let y = arguments[++__ks_i];
		if(y === void 0 || y === null) {
			throw new TypeError("'y' is not nullable");
		}
		let z = arguments.length > 4 && (__ks__ = arguments[++__ks_i]) !== void 0 ? __ks__ : null;
		return [u, v, x, y, z];
	}
	expect(function() {
		return foo();
	}).to.throw();
	expect(function() {
		return foo(1);
	}).to.throw();
	expect(foo(1, 2)).to.eql([null, 1, null, 2, null]);
	expect(foo(1, 2, 3)).to.eql([1, 2, null, 3, null]);
	expect(foo(1, 2, 3, 4)).to.eql([1, 2, 3, 4, null]);
	expect(foo(1, 2, 3, 4, 5)).to.eql([1, 2, 3, 4, 5]);
}