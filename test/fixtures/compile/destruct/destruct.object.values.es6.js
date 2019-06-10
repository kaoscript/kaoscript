var Helper = require("@kaoscript/runtime").Helper;
module.exports = function() {
	let __ks_0;
	let foo = Helper.default((__ks_0 = {
		foo: 2,
		qux: 9
	}).foo, 3), bar = Helper.default(__ks_0.bar, 6), qux = __ks_0.qux;
	console.log(foo, bar, qux);
	foo = Helper.default((__ks_0 = {
		foo: null
	}).foo, 3), bar = __ks_0.bar, qux = Helper.default(__ks_0.qux, 7);
	console.log(foo, bar, qux);
	foo = Helper.default(({
		bar: 2
	}).foo, 5);
	console.log(foo, bar, qux);
	({foo, bar, qux} = {
		foo: 2,
		qux: 9
	});
	console.log(foo, bar, qux);
};