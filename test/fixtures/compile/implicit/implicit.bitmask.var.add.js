const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	const Foobar = Helper.bitmask(Number, ["A", 0, "B", 1, "C", 2]);
	const mode = Foobar(Foobar.A | Foobar.C);
};