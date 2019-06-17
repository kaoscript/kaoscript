require("kaoscript/register");
function __ks_require(__ks_0) {
	var req = [];
	if(Type.isValue(__ks_0)) {
		req.push(__ks_0);
	}
	else {
		var foobar = require("./import.argument.object.export.type.ks")().foobar;
		req.push(foobar);
	}
	return req;
}
module.exports = function(__ks_0) {
	var [foobar] = __ks_require(__ks_0);
	var {String, __ks_String} = require("../_/_string.ks")();
	return {
		foobar: foobar,
		String: String,
		__ks_String: __ks_String
	};
};