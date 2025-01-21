#!/usr/bin/perl 
require "/www-smt/source/libs/dbconnect.pl";
# =============================================================================================
# _______________________________________________
#       Copyright (C)  INC.
#            NA Confidential
# _______________________________________________
#
# FILE_NAME        : rvs_view_progs_BU.pl
# CREATED BY       : 
# DATE             : 
# FILE VERSION     : 1.0
# PCR              : 
# CLEARCASE LABEL  : 
# CLEARCASE PATH   : 
# PRODUCTION PATH  : 
# COMMENT          : 
# FILE USAGE       : This file must be placed on an WEB enable environment with the 
#                    Perl system installed. The file must have execution 
#                    priviledges.
# REFERENCE LIST   : 
# CAUTIONS         : you need to disable anonymous access in the IIS.
#
# _______________________________________________
#
# DESCRIPTION  : This scripts display the components of a programs retrieving the data by
# 		 product, HW Version, plataform, machine.
# AUTHOR       : 
# DATE CREATED : 11052024
#
# MODIFICATION HISTORY:
#   Ver.        Date         Person                      Change
# =============================================================================================


# ===============================================
# Modules integration
# ===============================================
print "Content-type: text/html\n\n";
use strict;
use DBD::Oracle qw(:ora_types);
use Date::Calc qw(:all);
use CGI qw(:standard);
use CGI::Carp;
use CGI::Carp qw(fatalsToBrowser);

## CGI Handler
my $cgi = new CGI;

my $IsProd     = $cgi->param("dmProduct");
my $IsHw       = $cgi->param("dmHwVersion");
my $IsPlatform = $cgi->param("dmPlatform");
my $IsMachine  = $cgi->param("dmMachine");
my $sql ='';
my $message;



## ====================================================================
##         Check the Required Parameters
## ====================================================================

if ( ($IsProd eq "") || ($IsHw eq "") || ($IsPlatform eq "") )
{
	## ====================================================================
	##         Send a error Message
	## ====================================================================
	
	$message  = '                <p align="center"><b><font face="Arial" size="2">Parameters Error : The input parameters are incorrect,&nbsp;</font></b></p> ';
	$message .= '                <p align="center"><b><font face="Arial" size="2">please verify the fields and submit again</font></b></p> ';
	$message .= '                <p align="center"><input type="button" id="oBtnFormat" value="Go Back" onclick="history.go(-1);" ></p> ';
	&error_messages($message);
}


### ====================================================================
##         Connect the Database
## ====================================================================
my $dbh = connectDB("SMT_CONN");
if (!defined $dbh)  {
	print dberrorstr();
	exit(0);
}
## ====================================================================
##         Execute the query
## ====================================================================

print <<HTML_header;
<!--TOOLBAR_START-->
<!--TOOLBAR_EXEMPT-->
<!--TOOLBAR_END-->
<html>
   <head>
<!--
========================================================================
   F O X C O N N   P R O P E R T Y 
========================================================================

 Author        :    
 Date Created  :    17062024
 File Version  :    0.1
 Modified by   : 

========================================================================
                   Company
           (c) Copyright 2003, 
-->   
	<title>Results</title>
<xml>
<MSHelp:Keyword Index="A" Term="qual"/>
</xml>
<style>
tbody        { font-family: Arial; font-size: 8pt }
thead        { font-family: Arial; font-size: 8pt; font-weight: bold }
input{ filter:progid:DXImageTransform.Microsoft.Gradient(GradientType=1, StartColorStr='#A0FFFFFF', EndColorStr='#FF999999') font-size: 8pt;  font-family: Verdana; border: '1 solid #666666' font-weight: bold} 
</style>
</head>
<body bgcolor="#EFEFEF" text="#4F4F4F" >

 <TABLE><TBODY>
HTML_header
  
	if ($IsMachine ne "")
	{
	 	$sql = ' and machine like \''.$IsMachine.'%\'';
	}
	my $sth_ret = $dbh->prepare(' Select product,hw_version,machine,platform,program,reference_designator,part_number,slot,feeder_type,nozzle,library,side_table,clusters,setup from rvs_programs where product = \''.$IsProd.'\' and hw_version = \''.$IsHw.'\' and platform = \''.$IsPlatform.'\' '.$sql.' order by machine, slot, reference_designator');

		
		
	$sth_ret->execute();
	my $mach = '';
	while (my @res = $sth_ret->fetchrow_array)
	{
if ($mach ne $res[2])
{
print <<HTML_data1;
	</TBODY></TABLE>
	<br><br>
	<table border="1" style="border-collapse: collapse;BORDER: black 1px solid; WIDTH: 99%; background-color:#EFEFEF;"
		borderColor="#999999" cellSpacing=0 cellPadding=2 border=1 dragcolor='gray' slcolor="#ffffcc" hlcolor="#BEC5DE" >
	<THEAD>
	   <tr>
	     	<td bgcolor="#000000"><font color="white">Product </font></td>
    		<td bgcolor="#000000"><font color="white">Machine</font></td>
    		<td bgcolor="#000000"><font color="white">Hw Version</font></td>
    		<td bgcolor="#000000"><font color="white">Platform</font></td>
    		<td bgcolor="#000000"><font color="white">Program</font></td>
    		<td bgcolor="#000000" colspan="4" align="right"><input type="button" rowspam="2" value="Delete All" onclick="deleteProg();" class="metal" ></td>
	   </tr>
        <TBODY>
	   <tr>
	    	<td>$res[0]</td>
	    	<td>$res[2]</td>
	    	<td>$res[1]</td>
	    	<td>$res[3]</td>
	    	<td>$res[4]</td>
	   </tr>
	</TBODY></TABLE>
	<br><br>
	<TABLE id="MyTable" style="border-collapse: collapse;behavior:url(tableAct.htc);BORDER: black 1px groove; WIDTH: 99%; background-color:#EFEFEF;"
		borderColor="#AAAAAA" cellSpacing="0" cellPadding="2" border="1px" dragcolor="lightsteelblue" slcolor="#ffd700" hlcolor="#B0C4DE" >
  	 <THEAD>
  	   <TR align="center">
    		<td width="100">Ref Des</td>
    		<td width="100">Part Num.</td>
    		<td width="100">Slot</td>
    		<td width="100">Fdr. type</td>
    		<td width="100">Nozzle</td>
    		<td width="100">Library</td>
    		<td width="100">Ld/Mesa</td>     
  	  	<td width="100">Clusters</td>    
    		<td width="100">Setup</td>    
  	   </TR>                      
        </THEAD>                     
        <TBODY>
HTML_data1
}

print <<HTML_data;
	   <tr>
	    <td>$res[5]</td>
	    <td>$res[6]</td>
	    <td>$res[7]</td>
	    <td>$res[8]</td>
	    <td>$res[9]</td>
	    <td>$res[10]</td>
	    <td>$res[11]</td>
	    <td>$res[12]</td>
	    <td>$res[13]</td>
	   </tr>
HTML_data
	$mach = $res[2];
	}

print <<HTML_footer;
	</TBODY>
	</TABLE>
      <p align="center"><b><font face="Arial" size="2">&nbsp;</font></b></td>
</body>                                                                      
	<script>
	function deleteProg()
{
		var rooth = 'rvs_delete_progs_BU.pl?dmProduct=$IsProd&dmHwVersion=$IsHw&dmPlatform=$IsPlatform&dmMachine=$IsMachine&dmUser='+window.parent.contents.oUserID.innerText ;
		if (confirm('Are you sure you want to delete the Program '))
			open(rooth,'main');
}
</script>                                                                            
</html>                                                                      
HTML_footer


$sth_ret->finish;
$dbh->disconnect;
exit(0);



# ___________________________________________________________________________________________
#
#     S U B R O U T I N E S
# ___________________________________________________________________________________________


sub error_messages
{

my $error = $_[0];

## ====================================================================
##         Print Database Connection Error
## ====================================================================

print <<HTML_error;
<html>

<head>
<meta http-equiv="Content-Type" content="text/html; charset=windows-1252">
<meta name="GENERATOR" content="Microsoft FrontPage 4.0">
<meta name="ProgId" content="FrontPage.Editor.Document">
<title>Error</title>
<style>
input{ filter:progid:DXImageTransform.Microsoft.Gradient(GradientType=1, StartColorStr='#A0FFFFFF', EndColorStr='#FF999999') font-size: 8pt;  font-family: Verdana; border: 1 solid #666666" font-weight: bold;}
</style>

</head>

<body bgcolor="#EFEFEF" text="#4F4F4F">

<table border="0" width="100%" height="100%">
  <tr>
    <td width="100%">
      <div align="center">
        <center>
        <table border="1" width="600">
          <tr>
            <td bgcolor="#4F4F4F"><font color="#FFFFFF">&nbsp;<font size="4" face="Arial">¤</font>
              <font face="Arial" size="2"><b>
              Error&nbsp;</b></font></font></td>
          </tr>
          <tr>
            <td >
              <blockquote>
                <p align="center">&nbsp;&nbsp;</p>
		 $error
              </blockquote>
            </td>
          </tr>
        </table>
        </center>
      </div>
      <p align="center"><b><font face="Arial" size="2">&nbsp;</font></b></td>
  </tr>
</table>

</body>

</html>
HTML_error

exit(0);
}
