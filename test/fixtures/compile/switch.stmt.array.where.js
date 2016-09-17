var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	let somePoint = [1, 1];
	let __ks_0 = ([x, y]) => (x === 0) && (y === 0);
	let __ks_1 = ([x, y]) => y === 0;
	let __ks_2 = ([x, y]) => x === 0;
	let __ks_3 = ([x, y]) => (-2 <= x && x <= 2) && (-2 <= y && y <= 2);
	if(Type.isArray(somePoint) && somePoint.length === 2 && __ks_0(somePoint)) {
		var [x, y] = somePoint;
		console.log("(0, 0) is at the origin");
	}
	else if(Type.isArray(somePoint) && somePoint.length === 2 && __ks_1(somePoint)) {
		var [x, y] = somePoint;
		console.log("(" + x + ", 0) is on the x-axis");
	}
	else if(Type.isArray(somePoint) && somePoint.length === 2 && __ks_2(somePoint)) {
		var [x, y] = somePoint;
		console.log("(0, " + y + ") is on the y-axis");
	}
	else if(Type.isArray(somePoint) && somePoint.length === 2 && __ks_3(somePoint)) {
		var [x, y] = somePoint;
		console.log("(" + x + ", " + y + ") is inside the box");
	}
	else if(Type.isArray(somePoint) && somePoint.length === 2) {
		var [x, y] = somePoint;
		console.log("(" + x + ", " + y + ") is outside of the box");
	}
	else {
		console.log("Not a point");
	}
}