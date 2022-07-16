const {Helper, Operator, Type} = require("@kaoscript/runtime");
module.exports = function() {
	let somePoint = [1, 1];
	let __ks_0 = ([x, y]) => (x === 0) && (y === 0);
	let __ks_1 = ([x, y]) => y === 0;
	let __ks_2 = ([x, y]) => x === 0;
	let __ks_3 = ([x, y]) => (Operator.lte(-2, x) && Operator.lte(x, 2)) && (Operator.lte(-2, y) && Operator.lte(y, 2));
	if(Type.isArray(somePoint) && somePoint.length === 2 && __ks_0(somePoint)) {
		let [x, y] = somePoint;
		console.log("(0, 0) is at the origin");
	}
	else if(Type.isArray(somePoint) && somePoint.length === 2 && __ks_1(somePoint)) {
		let [x, y] = somePoint;
		console.log(Helper.concatString("(", x, ", 0) is on the x-axis"));
	}
	else if(Type.isArray(somePoint) && somePoint.length === 2 && __ks_2(somePoint)) {
		let [x, y] = somePoint;
		console.log(Helper.concatString("(0, ", y, ") is on the y-axis"));
	}
	else if(Type.isArray(somePoint) && somePoint.length === 2 && __ks_3(somePoint)) {
		let [x, y] = somePoint;
		console.log(Helper.concatString("(", x, ", ", y, ") is inside the box"));
	}
	else if(Type.isArray(somePoint) && somePoint.length === 2) {
		let [x, y] = somePoint;
		console.log(Helper.concatString("(", x, ", ", y, ") is outside of the box"));
	}
	else {
		console.log("Not a point");
	}
};