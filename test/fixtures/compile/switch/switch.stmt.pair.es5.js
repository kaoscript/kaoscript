var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	var pair = [2, -2];
	var __ks_0 = function(__ks__) {
		var x = __ks__[0], y = __ks__[1];
		return x === y;
	};
	var __ks_1 = function(__ks__) {
		var x = __ks__[0], y = __ks__[1];
		return (x + y) === 0;
	};
	var __ks_2 = function(__ks__) {
		var x = __ks__[0];
		return (x % 2) === 1;
	};
	if(Type.isArray(pair) && pair.length === 2 && __ks_0(pair)) {
		var x = pair[0], y = pair[1];
		console.log("These are twins");
	}
	else if(Type.isArray(pair) && pair.length === 2 && __ks_1(pair)) {
		var x = pair[0], y = pair[1];
		console.log("Antimatter, kaboom!");
	}
	else if(Type.isArray(pair) && pair.length === 2 && __ks_2(pair)) {
		var x = pair[0];
		console.log("The first one is odd");
	}
	else {
		console.log("No correlation...");
	}
};