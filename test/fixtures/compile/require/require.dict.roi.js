require("kaoscript/register");
var {Dictionary, Type} = require("@kaoscript/runtime");
module.exports = function(__ks_Dictionary) {
	if(!Type.isValue(__ks_Dictionary)) {
		var __ks_Dictionary = require("./require.dict.genesis.ks")().__ks_Dictionary;
	}
	return {
		__ks_Dictionary: __ks_Dictionary
	};
};