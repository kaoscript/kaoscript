module.exports = function() {
	let x = 1;
	let y = 3;
	console.log(x + y);
	console.log("foo" + x + y + "bar");
	console.log("foo" + (x + y) + "bar");
};