require("kaoscript/register");
module.exports = function() {
	var {Function, __ks_Function} = require("../_/_function.ks")();
	var {Template, template} = require("./import.sealed.function.source.ks")();
	function foo() {
		return 42;
	}
	console.log(__ks_Function._im_toSource(foo));
	console.log(__ks_Function._im_toSource(template.compile()));
	console.log(__ks_Function._im_toSource((new Template()).compile()));
};