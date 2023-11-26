const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	const CardSuit = Helper.enum(String, "Clubs", "clb", "Diamonds", "dmd", "Hearts", "hrt", "Spades", "spd");
	let card = CardSuit.Clubs;
	console.log(card);
};