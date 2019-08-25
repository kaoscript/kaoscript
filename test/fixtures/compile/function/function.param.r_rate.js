var Type = require("@kaoscript/runtime").Type;
module.exports = function(expect) {
	let foo = (function() {
		return function() {
			if(arguments.length < 1) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
			}
			let __ks_i = -1;
			let items = Array.prototype.slice.call(arguments, ++__ks_i, __ks_i = arguments.length - 1);
			let __ks__;
			let values = [];
			--__ks_i;
			let __ks_l = __ks_i + 2;
			while(++__ks_i < __ks_l) {
				__ks__ = arguments[__ks_i];
				if(__ks__ === void 0 || __ks__ === null || !Type.isNumber(__ks__)) {
					throw new TypeError("'values' is not of type 'Number'");
				}
				else {
					values.push(__ks__);
				}
			}
			return [items, values];
		};
	})();
	expect(function() {
		return foo();
	}).to.throw();
	expect(foo(1)).to.eql([[], [1]]);
	expect(foo(1, 2)).to.eql([[1], [2]]);
	expect(foo(1, 2, 3)).to.eql([[1, 2], [3]]);
	expect(foo(1, 2, 3, 4)).to.eql([[1, 2, 3], [4]]);
	expect(foo(1, 2, 3, 4, 5)).to.eql([[1, 2, 3, 4], [5]]);
	expect(foo(1, 2, 3, 4, 5, 6)).to.eql([[1, 2, 3, 4, 5], [6]]);
	expect(foo(1, 2, 3, 4, 5, 6, 7)).to.eql([[1, 2, 3, 4, 5, 6], [7]]);
};