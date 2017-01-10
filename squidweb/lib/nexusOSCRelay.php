<?php
	/* 	Example of using the NexusUI library with php relaying OSC messages
	*		Jesse Allison 2012 - allisonic.com - 
	*/
include 'OSC.phps';
/* get AJAX parameter */
/*$q=$_GET["data"];  /* Receive data parameter in get request ?data=blah*/
$q=$_POST["data"];	/* Receive data parameter as a post */
if (preg_match('/ /', $q)) {
	//list
	$q = (string)$q;
	//$q = preg_split('/ /', $q);
} else if (preg_match('/[a-z]/i', $q)) {
	//string
	$q = (string)$q;
} else if (preg_match('/[0-9]/i', $q)) {
	//number
	$q = (float)$q;
	$q =floatval($q);
}
$osc_name=$_POST["oscName"];	/* Get osc name to use as the osc message */
//$osc_ip=$_POST["oscIp"];	/* If an osc_ip is posted as well, use that ip, otherwise, default to localhost */
//if (is_null($osc_ip))
	$osc_ip='127.0.0.1';
							/* Relay the OSC message */
$c = new OSCClient();
$c->set_destination($osc_ip, 1000);
$c->send(new OSCMessage($osc_name, array($q)));
//$c->send(new OSCMessage($osc_name, $q));
echo "Got it";	/* If you want to send something back to the browser that sent the AJAX request. */
?>