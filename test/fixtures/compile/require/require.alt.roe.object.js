const {Type} = require("@kaoscript/runtime");
module.exports = function(__ks_Object) {
	if(!Type.isValue(__ks_Object)) {
		__ks_Object = {};
	}
	return {
		__ks_Object
	};
};