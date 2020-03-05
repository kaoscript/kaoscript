var Type = require("@kaoscript/runtime").Type;
module.exports = function(expect) {
	let foo = (() => {
		return function() {
			if(arguments.length < 1) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
			}
			let __ks_i = -1;
			let items = [];
			let __ks__ = arguments.length - 1;
			while(__ks__ > ++__ks_i) {
				if(Type.isNumber(arguments[__ks_i])) {
					items.push(arguments[__ks_i]);
				}
				else {
					--__ks_i;
					break;
				}
			}
			let x = arguments[__ks_i];
			if(x === void 0 || x === null) {
				throw new TypeError("'x' is not nullable");
			}
			return [items, x];
		};
	})();
	expect(() => {
		return foo();
	}).to.throw();
	expect(foo(1)).to.eql([[], 1]);
	expect(foo(1, 2)).to.eql([[1], 2]);
	expect(foo(1, 2, 3, 4)).to.eql([[1, 2, 3], 4]);
};