require("kaoscript/register");
var Dictionary = require("@kaoscript/runtime").Dictionary;
module.exports = function() {
	var __ks_Dictionary = require("./require.dict.genesis.ks")().__ks_Dictionary;
	return {
		__ks_Dictionary: __ks_Dictionary
	};
};