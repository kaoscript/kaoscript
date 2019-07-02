require("kaoscript/register");
var Type = require("@kaoscript/runtime").Type;
function __ks_require(__ks_0) {
	var req = [];
	if(Type.isValue(__ks_0)) {
		req.push(__ks_0);
	}
	else {
		var template = require("./import.sealed.function.source.ks")().template;
		req.push(template);
	}
	return req;
}
module.exports = function(__ks_0) {
	var [template] = __ks_require(__ks_0);
	var {Function, __ks_Function} = require("../_/_function.ks")();
	function foo() {
		return 42;
	}
	console.log(__ks_Function._im_toSource(foo));
	console.log(__ks_Function._im_toSource(template.compile()));
	return {
		template: template
	};
};