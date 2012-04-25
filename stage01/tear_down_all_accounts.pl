#!/usr/bin/perl
use strict;
use Cwd;

require "./lib_for_euare.pl";
require "./lib_for_euare_policy.pl";
require "./lib_for_euare_teardown.pl";

$ENV{'EUCALYPTUS'} = "/opt/eucalyptus";


################################################## TEAR DOWN ALL ACCOUNTS . PL #########################################################


###
### read the input list
###

print "\n";
print "########################### READ INPUT FILE  ##############################\n";

read_input_file();

my $clc_ip = $ENV{'QA_CLC_IP'};
my $source_lst = $ENV{'QA_SOURCE'};

if( $clc_ip eq "" ){
	print "[ERROR]\tCouldn't find CLC's IP !\n";
	exit(1);
};

if( $source_lst eq "PACKAGE" || $source_lst eq "REPO" ){
        $ENV{'EUCALYPTUS'} = "";
};


###
### clean up all the pre-existing credentials
###

print "\n";
print "########################### CLEAN UP CREDENTIALS  ##############################\n";

print "\n";
print("ssh -o StrictHostKeyChecking=no root\@$clc_ip \"cd /root; rm -f *_cred.zip; rm -fr /root/cred_depot/eucalyptus/admin \"\n");
system("ssh -o StrictHostKeyChecking=no root\@$clc_ip \"cd /root; rm -f *_cred.zip; rm -fr /root/cred_depot/eucalytpus/admin \" ");
print "\n";


print "\n\n\n\n\n";

print "\n";
print "\n";
print "+++++++++++++++++++++++++++++++++++++++ Get the Credntials for Account \"eucalyptus\"++++++++++++++++++++++++++++++++++++++++++++\n";
print "\n";
print "\n";

###
### create eucalyptus account crdentials
###
my $account_name = "eucalyptus";

my $count = 1;
while( $count > 0 ){
	if( get_user_credentials($account_name, "admin") == 0 ){
		$count = 0;
	}else{
		print "Trial $count\tCould Not Create Account \'$account_name\' Credentials\n";
		$count++;
		if( $count > 60 ){
			print "[TEST_REPORT]\tFAILED to Create Account \'$account_name\' Credentials !!!\n";
			exit(1);
		};
		sleep(1);
	};
};
print "\n";


###
### move the account credentials on /root/account_cred of CLC machine
###

unzip_cred_on_clc($account_name, "admin");
print "\n";

print "\n\n\n\n\n";

print "\n";
print "\n";
print "+++++++++++++++++++++++++++++++++++ Get the List of Accounts ++++++++++++++++++++++++++++++++++++++\n";
print "\n";
print "\n";


###
### get all accounts
###

my $out = get_all_accounts();
print "$out\n";
print "\n";


###
### get accounts in array
###
$out = get_list_of_accounts($out);
print "Accounts List\n";
print "$out\n";
print "\n";

my @account_array = split(" ", $out);

print "\n\n\n\n\n";

print "\n";
print "\n";
print "+++++++++++++++++++++++++++++++++++ Tear Down All Accounts ++++++++++++++++++++++++++++++++++++++\n";
print "\n";
print "\n";


###
### tear down all accounts
###

foreach my $account (@account_array){

	print "\n\n\n\n\n";

	print "\n";
	print "\n";
	print "+++++++++++++++++++++++++++++++++++ Tear Down Account \"$account\" ++++++++++++++++++++++++++++++++++++++\n";
	print "\n";
	print "\n";

	system("perl ./teardown_account.pl $account");
	print "\n";
};


print "\n\n\n\n\n";

print "\n";
print "\n";
print "+++++++++++++++++++++++++++++++++++ Remove All Accounts ++++++++++++++++++++++++++++++++++++++\n";
print "\n";
print "\n";

remove_all_accounts();
print "\n";


print "\n\n\n\n\n";

###
### End of Script
###

print "\n";
print "[TEST_REPORT]\tTEAR DOWN ALL ACCOUNTS HAS BEEN COMPLETED\n";
print "\n";

exit(0);

1;

##################### SUB-ROUTINES ############################

