const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	const Foobar = Helper.enum(Number, 0, "FOOBAR", 0);
	console.log(Foobar.FOOBAR);
};