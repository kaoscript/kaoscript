require("kaoscript/register");
const {Dictionary, Type} = require("@kaoscript/runtime");
module.exports = function(__ks_Dictionary) {
	if(!Type.isValue(__ks_Dictionary)) {
		var __ks_Dictionary = require("./.require.dict.genesis.ks.np51g.ksb")().__ks_Dictionary;
	}
	return {
		__ks_Dictionary
	};
};