var Helper = require("@kaoscript/runtime").Helper;
module.exports = function() {
	let NS = Helper.namespace(function() {
		function foo() {
		}
		return {
			foo: foo
		};
	});
	return {
		ns: NS
	};
};