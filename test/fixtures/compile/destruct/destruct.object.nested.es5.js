module.exports = function() {
	var foo = {
		bar: {
			n1: "hello",
			n2: "world"
		}
	};
	var __ks_0;
	var n1 = foo.bar.n1, qux = foo.bar.n2;
	console.log(n1, qux);
};