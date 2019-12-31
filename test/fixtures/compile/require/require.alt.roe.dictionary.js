var {Dictionary, Type} = require("@kaoscript/runtime");
module.exports = function(__ks_Dictionary) {
	if(!Type.isValue(__ks_Dictionary)) {
		__ks_Dictionary = {};
	}
};