const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	const CardSuit = Helper.enum(Number, 0, "Clubs", 100, "Diamonds", 110, "Hearts", 120, "Spades", 130);
};