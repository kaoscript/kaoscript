require("kaoscript/register");
var Type = require("@kaoscript/runtime").Type;
module.exports = function(Template, template) {
	var __ks_Function = require("../_/_function.ks")().__ks_Function;
	var __ks_0_valuable = Type.isValue(Template);
	var __ks_1_valuable = Type.isValue(template);
	if(!__ks_0_valuable || !__ks_1_valuable) {
		var __ks__ = require("./import.systemic.function.source.ks")();
		if(!__ks_0_valuable) {
			Template = __ks__.Template;
		}
		if(!__ks_1_valuable) {
			template = __ks__.template;
		}
	}
	function foo() {
		return 42;
	}
	console.log(__ks_Function._im_toSource(foo));
	console.log(__ks_Function._im_toSource(template.compile()));
};