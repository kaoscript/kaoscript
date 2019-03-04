require("kaoscript/register");
function __ks_require(__ks_0, __ks_1) {
	var req = [];
	if(Type.isValue(__ks_0)) {
		req.push(__ks_0);
	}
	else {
		var {Template, template} = require("./import.sealed.function.source.ks")();
		req.push(Template);
	}
	if(Type.isValue(__ks_1)) {
		req.push(__ks_1);
	}
	else {
		var {Template, template} = require("./import.sealed.function.source.ks")();
		req.push(template);
	}
	return req;
}
module.exports = function(__ks_0, __ks_1) {
	var [Template, template] = __ks_require(__ks_0, __ks_1);
	var {Function, __ks_Function} = require("../_/_function.ks")();
	function foo() {
		return 42;
	}
	console.log(__ks_Function._im_toSource(foo));
	console.log(__ks_Function._im_toSource(template.compile()));
};