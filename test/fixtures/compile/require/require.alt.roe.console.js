var Type = require("@kaoscript/runtime").Type;
function __ks_require(__ks_0) {
	if(Type.isValue(__ks_0)) {
		return [__ks_0];
	}
	else {
		return [console];
	}
}
module.exports = function(__ks_0) {
	var [console] = __ks_require(__ks_0);
	return {
		console: console
	};
};