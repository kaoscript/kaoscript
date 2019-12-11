require("kaoscript/register");
module.exports = function() {
	var {Pair, Triple} = require("./struct.array.extends.named.ks")();
	const triple = Triple("x", 0.1, true);
	console.log(triple[0], triple[1] + 1, !triple[2]);
};