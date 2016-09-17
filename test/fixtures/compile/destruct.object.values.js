module.exports = function() {
	var {foo = 3} = {
		foo: 2
	};
	console.log(foo);
	var {foo = 3} = {
		foo: null
	};
	console.log(foo);
	var {foo = 5} = {
		bar: 2
	};
	console.log(foo);
}