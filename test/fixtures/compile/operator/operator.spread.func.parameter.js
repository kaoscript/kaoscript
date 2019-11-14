module.exports = function() {
	let bar = [];
	function foo(...args) {
		bar.push(...args);
	}
};