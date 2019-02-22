module.exports = function() {
	var __ks_0;
	var foo = Type.isValue(__ks_0 = {
		foo: 2
	}.foo) ? __ks_0 : 3;
	console.log(foo);
	var foo = Type.isValue(__ks_0 = {
		foo: null
	}.foo) ? __ks_0 : 3;
	console.log(foo);
	var foo = Type.isValue(__ks_0 = {
		bar: 2
	}.foo) ? __ks_0 : 5;
	console.log(foo);
};