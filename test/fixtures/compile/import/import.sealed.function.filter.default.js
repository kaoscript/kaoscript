require("kaoscript/register");
function __ks_require(__ks_0) {
	if(Type.isValue(__ks_0)) {
		return [__ks_0];
	}
	else {
		var template = require("./import.sealed.function.source.ks")().template;
		return [template];
	}
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