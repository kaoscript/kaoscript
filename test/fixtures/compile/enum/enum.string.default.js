const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	const CardSuit = Helper.enum(String, 0, "Clubs", "clubs", "Diamonds", "diamonds", "Hearts", "hearts", "Spades", "spades");
	let card = CardSuit.Clubs;
	console.log(card);
};