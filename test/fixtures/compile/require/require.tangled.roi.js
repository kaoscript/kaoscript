require("kaoscript/register");
var Type = require("@kaoscript/runtime").Type;
function __ks_require(__ks_0, __ks___ks_0) {
	var req = [];
	if(Type.isValue(__ks_0)) {
		req.push(__ks_0, __ks___ks_0);
	}
	else {
		var {Foobar, __ks_Foobar} = require("./require.tangled.augment.ks")();
		req.push(Foobar, __ks_Foobar);
	}
	return req;
}
module.exports = function(__ks_0, __ks___ks_0) {
	var [Foobar, __ks_Foobar] = __ks_require(__ks_0, __ks___ks_0);
	return {
		Foobar: Foobar,
		__ks_Foobar: __ks_Foobar
	};
};