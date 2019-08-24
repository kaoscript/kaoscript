var Type = require("@kaoscript/runtime").Type;
module.exports = function(expect) {
	let foo = (function() {
		return function() {
			if(arguments.length < 2) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 2)");
			}
			let __ks_i = -1;
			let __ks__;
			let items = [];
			let __ks_l = Math.min(arguments.length - 1, __ks_i + 4);
			while(++__ks_i < __ks_l) {
				__ks__ = arguments[__ks_i];
				if(__ks__ === void 0 || __ks__ === null || !Type.isNumber(__ks__)) {
					if(items.length >= 1) {
						break;
					}
					else {
						throw new TypeError("'items' is not of type 'Number'");
					}
				}
				else {
					items.push(__ks__);
				}
			}
			let values = [];
			--__ks_i;
			__ks_l = Math.min(arguments.length, __ks_i + 4);
			while(++__ks_i < __ks_l) {
				__ks__ = arguments[__ks_i];
				if(__ks__ === void 0 || __ks__ === null || !Type.isString(__ks__)) {
					throw new TypeError("'values' is not of type 'String'");
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
	expect(function() {
		return foo(1);
	}).to.throw();
	expect(function() {
		return foo(1, 2);
	}).to.throw();
	expect(foo(1, "foo")).to.eql([[1], ["foo"]]);
	expect(foo(1, 2, 3, "foo")).to.eql([[1, 2, 3], ["foo"]]);
	expect(foo(1, "foo", "bar", "qux")).to.eql([[1], ["foo", "bar", "qux"]]);
	expect(foo(1, 2, 3, "foo", "bar", "qux")).to.eql([[1, 2, 3], ["foo", "bar", "qux"]]);
	expect(function() {
		return foo(1, 2, 3, 4, "foo");
	}).to.throw();
};