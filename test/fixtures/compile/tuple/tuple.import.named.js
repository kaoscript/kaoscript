require("kaoscript/register");
module.exports = function() {
	var Pair = require("./.tuple.export.named.ks.j5k8r9.ksb")().Pair;
	const pair = Pair.__ks_new("x", 0.1);
	console.log(pair[0], pair[1] + 1);
	return {
		Pair
	};
};