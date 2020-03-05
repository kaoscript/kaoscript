var Type = require("@kaoscript/runtime").Type;
module.exports = function(expect) {
	let foo = (() => {
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
	expect(() => {
		return foo(1);
	}).to.throw();
	expect(() => {
		return foo(null);
	}).to.throw();
	expect(() => {
		return foo(true);
	}).to.throw();
	expect(foo("foo")).to.eql([["foo"]]);
	expect(() => {
		return foo("true", 1);
	}).to.throw();
	expect(() => {
		return foo("true", true);
	}).to.throw();
	expect(() => {
		return foo("true", null);
	}).to.throw();
	expect(foo("foo", "bar", "qux")).to.eql([["foo", "bar", "qux"]]);
	expect(() => {
		return foo("foo", "bar", "qux", 4);
	}).to.throw();
};