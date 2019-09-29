var {Helper, Type} = require("@kaoscript/runtime");
module.exports = function(expect) {
	let NS = Helper.namespace(function() {
		const foobar = 42;
		return {
			foobar: foobar
		};
	});
	expect(Type.isNamespace(NS)).to.equal(true);
	expect(NS.foobar).to.equal(42);
	function foobar() {
		if(arguments.length === 1 && Type.isNamespace(arguments[0])) {
			let __ks_i = -1;
			let x = arguments[++__ks_i];
			if(x === void 0 || x === null) {
				throw new TypeError("'x' is not nullable");
			}
			else if(!Type.isNamespace(x)) {
				throw new TypeError("'x' is not of type 'Namespace'");
			}
			return "namespace";
		}
		else if(arguments.length === 1 && Type.isNumber(arguments[0])) {
			let __ks_i = -1;
			let x = arguments[++__ks_i];
			if(x === void 0 || x === null) {
				throw new TypeError("'x' is not nullable");
			}
			else if(!Type.isNumber(x)) {
				throw new TypeError("'x' is not of type 'Number'");
			}
			return "number";
		}
		else if(arguments.length === 1) {
			let __ks_i = -1;
			let x = arguments[++__ks_i];
			if(x === void 0 || x === null) {
				throw new TypeError("'x' is not nullable");
			}
			return "any";
		}
		else {
			throw new SyntaxError("Wrong number of arguments");
		}
	};
	expect(foobar(NS)).to.equal("namespace");
	expect(foobar(NS.foobar)).to.equal("number");
};