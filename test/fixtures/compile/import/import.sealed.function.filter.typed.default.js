require("kaoscript/register");
var Type = require("@kaoscript/runtime").Type;
module.exports = function(template) {
	var {Function, __ks_Function} = require("../_/_function.ks")();
	if(!Type.isValue(template)) {
		var template = require("./import.sealed.function.source.ks")().template;
	}
	function foo() {
		return 42;
	}
	console.log(__ks_Function._im_toSource(foo));
	console.log(__ks_Function._im_toSource(template.compile()));
};