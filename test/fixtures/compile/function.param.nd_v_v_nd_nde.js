module.exports = function(expect) {
	let foo = function() {
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
		let x = arguments[++__ks_i];
		if(x === void 0 || x === null) {
			throw new TypeError("'x' is not nullable");
		}
		let y = arguments.length > 3 && (__ks__ = arguments[++__ks_i]) !== void 0 ? __ks__ : null;
		let z = arguments.length > 4 && (__ks__ = arguments[++__ks_i]) !== void 0 ? __ks__ : null;
		return [u, v, x, y, z];
	};
	expect(function() {
		return foo();
	}).to.throw();
	expect(function() {
		return foo(1);
	}).to.throw();
	expect(foo(1, 2)).to.eql([null, 1, 2, null, null]);
	expect(foo(1, 2, 3)).to.eql([1, 2, 3, null, null]);
	expect(foo(1, 2, 3, 4)).to.eql([1, 2, 3, 4, null]);
	expect(foo(1, 2, 3, 4, 5)).to.eql([1, 2, 3, 4, 5]);
}