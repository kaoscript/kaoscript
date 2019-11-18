require("kaoscript/register");
module.exports = function() {
	var Pair = require("./struct.array.export.default.ks")().Pair;
	const pair = Pair("x", 0.1);
	console.log(pair[0], pair[1] + 1);
	return {
		Pair: Pair
	};
};