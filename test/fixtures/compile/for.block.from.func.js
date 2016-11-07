module.exports = function() {
	let foo = {
		foo() {
			let i = 0;
		}
	};
	function bar() {
		for(let i = 0; i < 10; ++i) {
			console.log(i);
		}
	}
}