var ctx = document.getElementById("myChart").getContext("2d");

$.get("/github/stats/github-simple", function (data) {
	var myNewChart = new Chart(ctx).Line(data);
	console.log(data);
});

$.get("/github/user/repos", function (data) {
	console.log(data);
	for (repo in data) {
		$("#my_repos").append("<li><a href='#' onClick=\"githubChart('"+data[repo]+"')\">"+data[repo]+"</a></li>");
	}
});

function githubChart (repo) {
	$.get("/github/stats/" + repo, function (data) {
		var myNewChart = new Chart(ctx).Line(data);
		console.log(data);
	});
}