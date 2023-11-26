const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	const CardSuit = Helper.enum(Number, 0, "Clubs", 100, "Diamonds", 101, "Hearts", 102, "Spades", 103);
};