var Helper = require("@kaoscript/runtime").Helper;
module.exports = function() {
	var path = require("path");
	require("../require/require.string.ks")(Helper.cast(path.join(__dirname, "foobar.txt"), "String", false, null, "String"));
};