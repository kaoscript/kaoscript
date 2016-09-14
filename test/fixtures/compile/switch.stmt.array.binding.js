module.exports = function(Array, __ks_Array, Class, Function, __ks_Function, Object, __ks_Object, Type) {
	let somePoint = [1, 1];
	let __ks_0 = ([__ks_0, __ks_1]) => __ks_0 === 0 && __ks_1 === 0;
	let __ks_1 = ([, __ks_1]) => __ks_1 === 0;
	let __ks_2 = ([__ks_0, ]) => __ks_0 === 0;
	let __ks_3 = ([__ks_0, __ks_1]) => __ks_0 >= -2 && __ks_0 <= 2 && __ks_1 >= -2 && __ks_1 <= 2;
	if((Type.isArray(somePoint) && somePoint.length === 2 && __ks_0(somePoint))) {
		console.log("(0, 0) is at the origin");
	}
	else if((Type.isArray(somePoint) && somePoint.length === 2 && __ks_1(somePoint)) && Type.isArray(somePoint) && somePoint.length === 2) {
		var [x, ] = somePoint;
		console.log("(" + x + ", 0) is on the x-axis");
	}
	else if((Type.isArray(somePoint) && somePoint.length === 2 && __ks_2(somePoint)) && Type.isArray(somePoint) && somePoint.length === 2) {
		var [, y] = somePoint;
		console.log("(0, " + y + ") is on the y-axis");
	}
	else if((Type.isArray(somePoint) && somePoint.length === 2 && __ks_3(somePoint)) && Type.isArray(somePoint) && somePoint.length === 2) {
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