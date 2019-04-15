var Type = require("@kaoscript/runtime").Type;
module.exports = function(expect) {
	let foo = (function() {
		return function() {
			let __ks_i = -1;
			let x;
			if(arguments.length > 0 && (x = arguments[++__ks_i]) !== void 0) {
				if(x !== null && !Type.isNumber(x)) {
					throw new TypeError("'x' is not of type 'Number'");
				}
			}
			else {
				x = null;
			}
			let items = arguments.length > ++__ks_i ? Array.prototype.slice.call(arguments, __ks_i, __ks_i = arguments.length) : [];
			return [x, items];
		};
	})();
	expect(foo()).to.eql([null, []]);
	expect(foo(1)).to.eql([1, []]);
	expect(function() {
		return foo("foo");
	}).to.throw();
	expect(foo(1, 2)).to.eql([1, [2]]);
	expect(function() {
		return foo("foo", 1);
	}).to.throw();
	expect(foo(null, "foo", 1)).to.eql([null, ["foo", 1]]);
};