<html>
<head>
<title>EUCA MONKEY</title>

</head>

<body>

<div style="position:absolute; top: 30; right: 50;" >
<img src="./euca_new_logo.jpg" width=150>
</div>

<?php
	if( isset($_POST["Update"]) ){
		update_graphs();
	};

	######################## HTML BODY ####################################################################

	print "<table><tr><td valign=\"top\">";

	echo "EUCA MONKEY\n";

	print "<td valign=\"top\">";

	print "<form method=\"post\" action=\"$PHP_SELF\">";
	print "<input type=\"submit\" value=\"Refresh\" name=\"Refresh\" style=\"height: 1.6em; width: 5em\">";
	print "</form>";

	print "</tr></table>";

	echo "<hr>\n";
	echo "<div style=\"background:#41A317; padding:2px;\"></div><br>\n";

	$this_time = date("H:i:s");

	print "<table cellspacing=\"5\"><tr>";
	print "<td valign=\"top\" >";

	if( file_exists("./graphs/cloud_user_input.png" ) ){
		print "<font color=\"green\">CLOUD USER INPUT GRAPH</font><br>";
		print "<a href=\"./graphs/cloud_user_input.png?$this_time\" link=\"white\" vlink=\"white\">";
		print "<img src=\"./graphs/cloud_user_input.png?$this_time\" width=500><br>";
		print "</a>";
	}else{
		print "<img src=\"./graphs/monkey.jpg\"><br>";
	};
	echo "</td>";

	print "<td valign=\"top\">";

	if( file_exists("./graphs/actual_cloud_display.png" ) ){
		print "<font color=\"green\">ACTUAL CLOUD USER RESOURCE GRAPH</font><br>";
		print "<a href=\"./graphs/actual_cloud_display.png?$this_time\" link=\"white\" vlink=\"white\">";
		print "<img src=\"./graphs/actual_cloud_display.png?$this_time\" width=500><br>";
		print "</a>";
	}else{
		print "<img src=\"./graphs/monkey.jpg\"><br>";
	};
	echo "</td>";

	print "</tr></table>";

	print "<br>";

	print "<form method=\"post\" action=\"$PHP_SELF\">";
	print "<input type=\"submit\" value=\"Update\" name=\"Update\" style=\"height: 1.6em; width: 5em\">";
	print "</form>";

	echo "<hr>\n";
	echo "<div style=\"background:#41A317; padding:2px;\"></div><br>\n";

?>

</body>
</html>


