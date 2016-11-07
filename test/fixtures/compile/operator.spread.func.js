module.exports = function() {
	let bar = [];
	function foo(...args) {
		bar.push.apply(bar, args);
	}
}