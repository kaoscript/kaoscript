module.exports = function() {
	let left = 10;
	let right = 20;
	if(right > left) {
		[left, right] = [right, left];
	}
	console.log(left, right);
}