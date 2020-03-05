module.exports = function(expect) {
	let foo = (() => {
		return function() {
			if(arguments.length < 1) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
			}
			let __ks_i = -1;
			let __ks__;
			let x = arguments.length > 1 && (__ks__ = arguments[++__ks_i]) !== void 0 ? __ks__ : null;
			let y = arguments.length > 2 && (__ks__ = arguments[++__ks_i]) !== void 0 ? __ks__ : null;
			let z = arguments[++__ks_i];
			if(z === void 0 || z === null) {
				throw new TypeError("'z' is not nullable");
			}
			return [x, y, z];
		};
	})();
	expect(() => {
		return foo();
	}).to.throw();
	expect(foo(1)).to.eql([null, null, 1]);
	expect(foo(1, 2)).to.eql([1, null, 2]);
	expect(foo(1, 2, 3)).to.eql([1, 2, 3]);
};