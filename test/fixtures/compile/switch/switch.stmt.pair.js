var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	let pair = [2, -2];
	let __ks_0 = ([x, y]) => x === y;
	let __ks_1 = ([x, y]) => (x + y) === 0;
	let __ks_2 = ([x, ]) => (x % 2) === 1;
	if(Type.isArray(pair) && pair.length === 2 && __ks_0(pair)) {
		var [x, y] = pair;
		console.log("These are twins");
	}
	else if(Type.isArray(pair) && pair.length === 2 && __ks_1(pair)) {
		var [x, y] = pair;
		console.log("Antimatter, kaboom!");
	}
	else if(Type.isArray(pair) && pair.length === 2 && __ks_2(pair)) {
		var [x, ] = pair;
		console.log("The first one is odd");
	}
	else {
		console.log("No correlation...");
	}
};