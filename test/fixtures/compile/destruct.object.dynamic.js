module.exports = function() {
	let key = "qux";
	var {[key]: foo} = {
		qux: "bar"
	};
	console.log(foo);
}