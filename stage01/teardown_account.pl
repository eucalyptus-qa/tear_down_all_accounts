#!/usr/bin/perl
use strict;
use Cwd;

require "./lib_for_euare.pl";
require "./lib_for_euare_policy.pl";
require "./lib_for_euare_teardown.pl";

$ENV{'EUCALYPTUS'} = "/opt/eucalyptus";


################################################## TEARDOWN ACCOUNT . PL #########################################################


###
### check for arguments
###

my $given_account_name = "";

if ( @ARGV > 0 ){
	$given_account_name = shift @ARGV;
};

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
### check for TEST_ACCOUNT_NAME in MEMO
###

print "\n";
print "########################### GET ACCOUNT AND USER NAME  ##############################\n";

my $account_name = "default-qa-account";

if( $given_account_name ne "" ){
	$account_name = $given_account_name;
};

print "\n";
print "TEST ACCOUNT NAME [$account_name]\n";
print "\n";



###
### clean up all the pre-existing credentials
###

print "\n";
print "########################### CLEAN UP CREDENTIALS  ##############################\n";

print "\n";
print("ssh -o StrictHostKeyChecking=no root\@$clc_ip \"cd /root; rm -f *_cred.zip; rm -fr /root/cred_depot/eucalyptus/admin; rm -fr /root/cred_depot/$account_name/admin\"\n");
system("ssh -o StrictHostKeyChecking=no root\@$clc_ip \"cd /root; rm -f *_cred.zip; rm -fr /root/cred_depot/eucalytpus/admin; rm -fr /root/cred_depot/$account_name/admin\" ");
print "\n";


print "\n";
print "\n";
print "+++++++++++++++++++++++++++++++++++++++ Get the Credntials for Account \"$account_name\" ++++++++++++++++++++++++++++++++++++++++++++\n";
print "\n";
print "\n";

###
### create test account crdentials
###

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


print "\n";
print "\n";
print "+++++++++++++++++++++++++++++++++++ Get the List of Groups in Account \"$account_name\" ++++++++++++++++++++++++++++++++++++++\n";
print "\n";
print "\n";


###
### get groups
###

my $out = get_account_groups($account_name);
print "$out\n";
print "\n";


###
### get groups in array
###
$out = get_list_of_groups($out);
print "Groups List\n";
print "$out\n";
print "\n";

my @group_array = split(" ", $out);

print "\n";
print "\n";
print "+++++++++++++++++++++++++++++++++++ Remove All Policies in Groups in Account \"$account_name\" ++++++++++++++++++++++++++++++++++++++\n";
print "\n";
print "\n";


###
### Remove all policies in groups
###

foreach my $group (@group_array){
	remove_all_policies_in_group($account_name, $group);
};

print "\n";
print "\n";
print "+++++++++++++++++++++++++++++++++++ Remove All Users in Groups in Account \"$account_name\" ++++++++++++++++++++++++++++++++++++++\n";
print "\n";
print "\n";

###
### Remove all users in groups
###

foreach my $group (@group_array){
	remove_all_users_in_group($account_name, $group);
};

print "\n";
print "\n";
print "+++++++++++++++++++++++++++++++++++ Remove All Groups in Account \"$account_name\" ++++++++++++++++++++++++++++++++++++++\n";
print "\n";
print "\n";


###
### Remove all groups
###

remove_all_groups_in_account($account_name);
print "\n";

print "\n";
print "\n";
print "+++++++++++++++++++++++++++++++++++ Get the List of Users in Account \"$account_name\" ++++++++++++++++++++++++++++++++++++++\n";
print "\n";
print "\n";

###
### get users
###
$out = get_account_users($account_name);
print "$out\n";
print "\n";


###
### get users in array
###
$out = get_list_of_users($out);
print "Users List\n";
print "$out\n";
print "\n";

my @user_array = split(" ", $out);

print "\n";
print "\n";
print "+++++++++++++++++++++++++++++++++++ Remove All Policies in Groups in Account \"$account_name\" ++++++++++++++++++++++++++++++++++++++\n";
print "\n";
print "\n";


###
### Remove all policies in user
###

foreach my $user (@user_array){
	remove_all_policies_in_user($account_name, $user);
};


print "\n";
print "\n";
print "+++++++++++++++++++++++++++++++++++ Remove All Users in Account \"$account_name\" ++++++++++++++++++++++++++++++++++++++\n";
print "\n";
print "\n";

###
### Remove all users
###

remove_all_users_in_account($account_name);
print "\n";


###
### End of Script
###

print "\n";
print "[TEST_REPORT]\tTEAR DOWN ACCOUNT for Account \"$account_name\" HAS BEEN COMPLETED\n";
print "\n";

exit(0);

1;

##################### SUB-ROUTINES ############################

