const {Operator, Type} = require("@kaoscript/runtime");
module.exports = function() {
	let pair = [2, -2];
	let __ks_0 = ([x, y]) => x === y;
	let __ks_1 = ([x, y]) => Operator.addOrConcat(x, y) === 0;
	let __ks_2 = ([x, ]) => Operator.modulo(x, 2) === 1;
	if(Type.isArray(pair) && pair.length === 2 && __ks_0(pair)) {
		let [x, y] = pair;
		console.log("These are twins");
	}
	else if(Type.isArray(pair) && pair.length === 2 && __ks_1(pair)) {
		let [x, y] = pair;
		console.log("Antimatter, kaboom!");
	}
	else if(Type.isArray(pair) && pair.length === 2 && __ks_2(pair)) {
		let [x, ] = pair;
		console.log("The first one is odd");
	}
	else {
		console.log("No correlation...");
	}
};