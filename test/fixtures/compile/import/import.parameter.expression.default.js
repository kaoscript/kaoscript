module.exports = function() {
	var path = require("path");
	require("../require/require.string.ks")(path.join(__dirname, "foobar.txt"));
};