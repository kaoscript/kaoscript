var Type = require("@kaoscript/runtime").Type;
module.exports = function(expect) {
	let foo = (function() {
		return function() {
			let __ks_i = -1;
			let items = [];
			while(arguments.length > ++__ks_i) {
				if(Type.isString(arguments[__ks_i])) {
					items.push(arguments[__ks_i]);
				}
				else {
					throw new TypeError("'items' is not of type 'String'");
				}
			}
			return [items];
		};
	})();
	expect(foo()).to.eql([[]]);
	expect(function() {
		return foo(1);
	}).to.throw();
	expect(function() {
		return foo(null);
	}).to.throw();
	expect(function() {
		return foo(true);
	}).to.throw();
	expect(foo("foo")).to.eql([["foo"]]);
	expect(function() {
		return foo("true", 1);
	}).to.throw();
	expect(function() {
		return foo("true", true);
	}).to.throw();
	expect(function() {
		return foo("true", null);
	}).to.throw();
	expect(foo("foo", "bar", "qux")).to.eql([["foo", "bar", "qux"]]);
	expect(function() {
		return foo("foo", "bar", "qux", 4);
	}).to.throw();
};