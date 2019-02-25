module.exports = function() {
	let key = "qux";
	let {[key]: foo} = {
		qux: "bar"
	};
	console.log(foo);
};