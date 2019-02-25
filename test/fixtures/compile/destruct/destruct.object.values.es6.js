module.exports = function() {
	let {foo = 3} = {
		foo: 2
	};
	console.log(foo);
	var {foo: __ks_0 = 3} = {
		foo: null
	};
	foo = __ks_0;
	console.log(foo);
	var {foo: __ks_0 = 5} = {
		bar: 2
	};
	foo = __ks_0;
	console.log(foo);
};