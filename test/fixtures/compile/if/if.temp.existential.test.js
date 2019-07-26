var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	function foobar(scope, name) {
		if(arguments.length < 2) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 2)");
		}
		if(scope === void 0 || scope === null) {
			throw new TypeError("'scope' is not nullable");
		}
		if(name === void 0 || name === null) {
			throw new TypeError("'name' is not nullable");
		}
		let variable, __ks_0;
		if((Type.isValue(__ks_0 = scope.getVariable(name)) ? (variable = __ks_0, true) : false) && ((variable.name() !== name) || (variable.scope() !== scope))) {
			return variable.discard();
		}
		else {
			return null;
		}
	}
};