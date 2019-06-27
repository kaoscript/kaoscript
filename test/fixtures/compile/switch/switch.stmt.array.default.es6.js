var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	let somePoint = [1, 1];
	let __ks_0 = ([__ks_0, __ks_1]) => __ks_0 === 0 && __ks_1 === 0;
	let __ks_1 = ([, __ks_1]) => __ks_1 === 0;
	let __ks_2 = ([__ks_0, ]) => __ks_0 === 0;
	let __ks_3 = ([__ks_0, __ks_1]) => __ks_0 >= -2 && __ks_0 <= 2 && __ks_1 >= -2 && __ks_1 <= 2;
	if((Type.isArray(somePoint) && somePoint.length === 2 && __ks_0(somePoint))) {
		console.log("(0, 0) is at the origin");
	}
	else if((Type.isArray(somePoint) && somePoint.length === 2 && __ks_1(somePoint))) {
		console.log("(" + somePoint[0] + ", 0) is on the x-axis");
	}
	else if((Type.isArray(somePoint) && somePoint.length === 2 && __ks_2(somePoint))) {
		console.log("(0, " + somePoint[1] + ") is on the y-axis");
	}
	else if((Type.isArray(somePoint) && somePoint.length === 2 && __ks_3(somePoint))) {
		console.log("(" + somePoint[0] + ", " + somePoint[1] + ") is inside the box");
	}
	else if((Type.isArray(somePoint) && somePoint.length === 2)) {
		console.log("(" + somePoint[0] + ", " + somePoint[1] + ") is outside of the box");
	}
	else {
		console.log("Not a point");
	}
};