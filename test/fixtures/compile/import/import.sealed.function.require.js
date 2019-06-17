require("kaoscript/register");
function __ks_require(__ks_0, __ks_1) {
	var req = [];
	var __ks_0_valuable = Type.isValue(__ks_0);
	var __ks_1_valuable = Type.isValue(__ks_1);
	if(!__ks_0_valuable || !__ks_1_valuable) {
		var {Template, template} = require("./import.sealed.function.source.ks")();
		req.push(__ks_0_valuable ? __ks_0 : Template);
		req.push(__ks_1_valuable ? __ks_1 : template);
	}
	else {
		req.push(__ks_0, __ks_1);
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