var Type = require("@kaoscript/runtime").Type;
function __ks_require(__ks_0) {
	var req = [];
	if(Type.isValue(__ks_0)) {
		req.push(__ks_0);
	}
	else {
		req.push(console);
	}
	return req;
}
module.exports = function(__ks_0) {
	var [console] = __ks_require(__ks_0);
	return {
		console: console
	};
};