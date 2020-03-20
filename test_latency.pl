#!/usr/bin/env perl

use DBD::Oracle;

my $dbh = DBI->connect( "dbi:Oracle:E9CUST", 'ABNAPPC', 'ABNAPPC_2016' ) or die($DBI::errstr, "\n");



$query = "SELECT * FROM DUAL";
$query_handle = $dbh->prepare($query);

# EXECUTE THE QUERY

my $start = time;

 for (my $counter=0; $counter <10000 ; $counter++) {

 $query_handle->execute();

}

my $duration = time - $start;
print "Execution time: $duration s\n";

 $query_handle->finish();



 $dbh->disconnect;


