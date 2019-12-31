require("kaoscript/register");
var Type = require("@kaoscript/runtime").Type;
module.exports = function(template) {
	var __ks_Function = require("../_/_function.ks")().__ks_Function;
	if(!Type.isValue(template)) {
		var template = require("./import.systemic.function.source.ks")().template;
	}
	function foo() {
		return 42;
	}
	console.log(__ks_Function._im_toSource(foo));
	console.log(__ks_Function._im_toSource(template.compile()));
	return {
		template: template
	};
};