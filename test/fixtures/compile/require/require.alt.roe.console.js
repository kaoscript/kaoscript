var Type = require("@kaoscript/runtime").Type;
module.exports = function(__ks_0) {
	if(Type.isValue(__ks_0)) {
		console = __ks_0;
	}
	return {
		console: console
	};
};