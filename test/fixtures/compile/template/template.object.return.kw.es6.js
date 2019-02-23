module.exports = function() {
	let x = 24;
	function foo() {
		return {
			[x]: 42
		};
	}
};