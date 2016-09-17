module.exports = function() {
	let Color = {
		Red: 0,
		Green: 1,
		Blue: 2
	};
	console.log(Color.Red);
	Color.DarkRed = 3;
	Color.DarkGreen = 4;
	Color.DarkBlue = 5;
	console.log(Color.DarkGreen);
}