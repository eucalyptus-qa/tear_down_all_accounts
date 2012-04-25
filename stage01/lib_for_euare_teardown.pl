#!/usr/bin/perl
use strict;

########################## SUBROUTINES #####################################

sub get_all_accounts{
	print "\n";
	print "########################### GET-ALL-ACCOUNTS ##############################\n";

	### get all accounts
	print "$ENV{'QA_CLC_IP'} :: euare-accountlist\n";
	my $out = `ssh -o ServerAliveInterval=1 -o ServerAliveCountMax=5 -o StrictHostKeyChecking=no root\@$ENV{'QA_CLC_IP'} \"source /root/cred_depot/eucalyptus/admin/eucarc; euare-accountlist\"`;
	print "\n";

	return $out
};

sub get_list_of_accounts{
	my $buffer = shift @_;
	my $out = "";

	my @temp_array = split("\n", $buffer);
	foreach my $line (@temp_array){
		if( $line =~/^(\S+)\s+\d+/ ){
			$out .= $1 . " ";
		};
	};

	return $out;
};

sub remove_all_users_in_group{
	my $account = shift @_;
	my $group = shift @_;

	print "\n";
	print "########################### GET-ALL-USERS-IN-GROUP ##############################\n";

	### get all users in group
	print "$ENV{'QA_CLC_IP'} :: euare-grouplistusers -g $group\n";
	my $out = `ssh -o ServerAliveInterval=1 -o ServerAliveCountMax=5 -o StrictHostKeyChecking=no root\@$ENV{'QA_CLC_IP'} \"source /root/cred_depot/$account/admin/eucarc; euare-grouplistusers -g $group\"`;
	print "\n";
	print "$out\n";
	print "\n";

	my @user_array = split("\n", $out);
	foreach my $line (@user_array){
		if( $line =~/:user\/(.+)/ ){
			my $this_user = $1;
			print "Removing User " . $this_user . " from Group $group\n";
			if( remove_user_in_group($account, $group, $this_user) ){
				print "[TEST_REPORT]\tFAILED in removing user $this_user from group $group !!\n\n";
			};
		};
	};

	print "\n";
	print "########################### GET-ALL-USERS-IN-GROUP ##############################\n";

	### verify that users have been cleared off
	print "$ENV{'QA_CLC_IP'} :: euare-grouplistusers -g $group\n";
	my $out = `ssh -o ServerAliveInterval=1 -o ServerAliveCountMax=5 -o StrictHostKeyChecking=no root\@$ENV{'QA_CLC_IP'} \"source /root/cred_depot/$account/admin/eucarc; euare-grouplistusers -g $group\"`;
	print "\n";
	print "$out\n";
	if( $out =~/:user\/(.+)/m ){
		print "[TEST_REPORT]\tFAILED in removing all users from group $group !!\n\n";
	};

	print "[TEST_REPORT]\tSucceeded in removing all users from group $group\n\n";

	return 0;
};


sub remove_user_in_group{
	my $account = shift @_;
	my $group = shift @_;
	my $user = shift @_;

	print "\n";
	print "########################### REMOVE-USER-IN-GROUP ##############################\n";

        ### get user in group
        print "$ENV{'QA_CLC_IP'} :: euare-groupremoveuser -g $group -u $user\n";
        system("ssh -o ServerAliveInterval=1 -o ServerAliveCountMax=5 -o StrictHostKeyChecking=no root\@$ENV{'QA_CLC_IP'} \"source /root/cred_depot/$account/admin/eucarc; euare-groupremoveuser -g $group -u $user \" ");
        print "\n";

	### verify the removal
        print "$ENV{'QA_CLC_IP'} :: euare-grouplistusers -g $group\n";
        my $out = `ssh -o ServerAliveInterval=1 -o ServerAliveCountMax=5 -o StrictHostKeyChecking=no root\@$ENV{'QA_CLC_IP'} \"source /root/cred_depot/$account/admin/eucarc; euare-grouplistusers -g $group\" `;
        print "\n";
        print "$out\n";
        print "\n";

	if( $out =~ /:user\/$user$/m ){
		return 1;
	};

	return 0;
};

sub remove_all_policies_in_group{
	my $account = shift @_;
	my $group = shift @_;

	print "\n";
	print "########################### GET-ALL-POLICIES-IN-GROUP ##############################\n";

	### get all policies in group
	print "$ENV{'QA_CLC_IP'} :: euare-grouplistpolicies -g $group\n";
	my $out = `ssh -o ServerAliveInterval=1 -o ServerAliveCountMax=5 -o StrictHostKeyChecking=no root\@$ENV{'QA_CLC_IP'} \"source /root/cred_depot/$account/admin/eucarc; euare-grouplistpolicies -g $group\"`;
	print "\n";
	print "$out\n";
	print "\n";

	my @pol_array = split("\n", $out);
	foreach my $line (@pol_array){
		if( $line =~/^(.+)/ ){
			my $this_pol = $1;
			print "Removing Policy " . $this_pol . " from Group $group\n";
			if( remove_policy_in_group($account, $group, $this_pol) ){
				print "[TEST_REPORT]\tFAILED in removing policy $this_pol from group $group !!\n\n";
			};
		};
	};

	print "\n";
	print "########################### GET-ALL-POLICIES-IN-GROUP ##############################\n";

	### verify that policies have been cleared off
	print "$ENV{'QA_CLC_IP'} :: euare-grouplistpolicies -g $group\n";
	my $out = `ssh -o ServerAliveInterval=1 -o ServerAliveCountMax=5 -o StrictHostKeyChecking=no root\@$ENV{'QA_CLC_IP'} \"source /root/cred_depot/$account/admin/eucarc; euare-grouplistpolicies -g $group\"`;
	print "\n";
	print "$out\n";
	if( $out =~/^(.+)/m ){
		print "[TEST_REPORT]\tFAILED in removing all policies from group $group !!\n\n";
	};

	print "[TEST_REPORT]\tSucceeded in removing all policies from group $group\n\n";

	return 0;
};


sub remove_policy_in_group{
	my $account = shift @_;
	my $group = shift @_;
	my $policy = shift @_;

	print "\n";
	print "########################### REMOVE-POLICY-IN-GROUP ##############################\n";

        ### get user in group
        print "$ENV{'QA_CLC_IP'} :: euare-groupdelpolicy -g $group -p $policy\n";
        system("ssh -o ServerAliveInterval=1 -o ServerAliveCountMax=5 -o StrictHostKeyChecking=no root\@$ENV{'QA_CLC_IP'} \"source /root/cred_depot/$account/admin/eucarc; euare-groupdelpolicy -g $group -p $policy \" ");
        print "\n";

	### verify the removal
        print "$ENV{'QA_CLC_IP'} :: euare-grouplistpolicies -g $group\n";
        my $out = `ssh -o ServerAliveInterval=1 -o ServerAliveCountMax=5 -o StrictHostKeyChecking=no root\@$ENV{'QA_CLC_IP'} \"source /root/cred_depot/$account/admin/eucarc; euare-grouplistpolicies -g $group\" `;
        print "\n";
        print "$out\n";
        print "\n";

	if( $out =~ /^$policy$/m ){
		return 1;
	};

	return 0;
};



sub remove_all_groups_in_account{
	my $account = shift @_;

	print "\n";
	print "########################### GET-ALL-GROUPS-IN-ACCOUNT ##############################\n";

	### get all groups in account
	print "$ENV{'QA_CLC_IP'} :: euare-grouplistbypath\n";
	my $out = `ssh -o ServerAliveInterval=1 -o ServerAliveCountMax=5 -o StrictHostKeyChecking=no root\@$ENV{'QA_CLC_IP'} \"source /root/cred_depot/$account/admin/eucarc; euare-grouplistbypath \"`;
	print "\n";
	print "$out\n";
	print "\n";

	my @group_array = split("\n", $out);
	foreach my $line (@group_array){
		if( $line =~/:group\/(.+)/ ){
			my $this_group = $1;
			print "Removing Group " . $this_group . " from Account $account\n";
			if( remove_group_in_account($account, $this_group) ){
				print "[TEST_REPORT]\tFAILED in removing group $this_group from account $account !!\n\n";
			};
		};
	};

	print "\n";
	print "########################### GET-ALL-GROUPS-IN-ACCOUNT ##############################\n";

	### verify that groups have been cleared off
	print "$ENV{'QA_CLC_IP'} :: euare-grouplistbypath\n";
	my $out = `ssh -o ServerAliveInterval=1 -o ServerAliveCountMax=5 -o StrictHostKeyChecking=no root\@$ENV{'QA_CLC_IP'} \"source /root/cred_depot/$account/admin/eucarc; euare-grouplistbypath\"`;
	print "\n";
	print "$out\n";
	if( $out =~/:group\/(.+)/m ){
		print "[TEST_REPORT]\tFAILED in removing all groups from account $account !!\n\n";
	};

	print "[TEST_REPORT]\tSucceeded in removing all groups from group $account\n\n";

	return 0;
};


sub remove_group_in_account{
	my $account = shift @_;
	my $group = shift @_;

	print "\n";
	print "########################### DELETE-GROUP-IN-ACCOUNT ##############################\n";

        ### remove group in account
        print "$ENV{'QA_CLC_IP'} :: euare-groupdel -g $group\n";
        system("ssh -o ServerAliveInterval=1 -o ServerAliveCountMax=5 -o StrictHostKeyChecking=no root\@$ENV{'QA_CLC_IP'} \"source /root/cred_depot/$account/admin/eucarc; euare-groupdel -g $group \" ");
        print "\n";

	### verify the removal
        print "$ENV{'QA_CLC_IP'} :: euare-grouplistbypath\n";
        my $out = `ssh -o ServerAliveInterval=1 -o ServerAliveCountMax=5 -o StrictHostKeyChecking=no root\@$ENV{'QA_CLC_IP'} \"source /root/cred_depot/$account/admin/eucarc; euare-grouplistbypath\" `;
        print "\n";
        print "$out\n";
        print "\n";

	if( $out =~ /:group\/$group$/m ){
		return 1;
	};

	return 0;
};



sub remove_all_users_in_account{
	my $account = shift @_;

	print "\n";
	print "########################### GET-ALL-USERS-IN-ACCOUNT ##############################\n";

	### get all users in account
	print "$ENV{'QA_CLC_IP'} :: euare-userlistbypath\n";
	my $out = `ssh -o ServerAliveInterval=1 -o ServerAliveCountMax=5 -o StrictHostKeyChecking=no root\@$ENV{'QA_CLC_IP'} \"source /root/cred_depot/$account/admin/eucarc; euare-userlistbypath \"`;
	print "\n";
	print "$out\n";
	print "\n";

	my @user_array = split("\n", $out);
	foreach my $line (@user_array){
		if( $line =~/:user\/(.+)/ ){
			my $this_user = $1;
			if( $this_user ne "admin" ){
				print "Removing User " . $this_user . " from Account $account\n";
				if( remove_user_in_account($account, $this_user) ){
					print "[TEST_REPORT]\tFAILED in removing user $this_user from account $account !!\n\n";
				};
			};
		};
	};

	print "\n";
	print "########################### GET-ALL-USERS-IN-ACCOUNT ##############################\n";

	### verify that groups have been cleared off
	print "$ENV{'QA_CLC_IP'} :: euare-userlistbypath\n";
	my $out = `ssh -o ServerAliveInterval=1 -o ServerAliveCountMax=5 -o StrictHostKeyChecking=no root\@$ENV{'QA_CLC_IP'} \"source /root/cred_depot/$account/admin/eucarc; euare-userlistbypath\"`;
	print "\n";
	print "$out\n";
	if( $out =~/:user\/(.+)/m ){
		if( $1 ne "admin" ){
			print "[TEST_REPORT]\tFAILED in removing all users from account $account !!\n\n";
		};
	};

	print "[TEST_REPORT]\tSucceeded in removing all users from group $account\n\n";

	return 0;
};


sub remove_user_in_account{
	my $account = shift @_;
	my $user = shift @_;

	print "\n";
	print "########################### DELETE-USER-IN-ACCOUNT ##############################\n";

        ### remove user in account
        print "$ENV{'QA_CLC_IP'} :: euare-userdel -R -u $user\n";
        system("ssh -o ServerAliveInterval=1 -o ServerAliveCountMax=5 -o StrictHostKeyChecking=no root\@$ENV{'QA_CLC_IP'} \"source /root/cred_depot/$account/admin/eucarc; euare-userdel -R -u $user \" ");
	print "\n";

	### verify the removal
        print "$ENV{'QA_CLC_IP'} :: euare-userlistbypath\n";
        my $out = `ssh -o ServerAliveInterval=1 -o ServerAliveCountMax=5 -o StrictHostKeyChecking=no root\@$ENV{'QA_CLC_IP'} \"source /root/cred_depot/$account/admin/eucarc; euare-userlistbypath\" `;
        print "\n";
        print "$out\n";
        print "\n";

	if( $out =~ /:user\/$user$/m ){
		return 1;
	};

	return 0;
};


sub remove_all_policies_in_user{
	my $account = shift @_;
	my $user = shift @_;

	print "\n";
	print "########################### GET-ALL-POLICIES-IN-USER ##############################\n";

	### get all policies in user
	print "$ENV{'QA_CLC_IP'} :: euare-userlistpolicies -u $user\n";
	my $out = `ssh -o ServerAliveInterval=1 -o ServerAliveCountMax=5 -o StrictHostKeyChecking=no root\@$ENV{'QA_CLC_IP'} \"source /root/cred_depot/$account/admin/eucarc; euare-userlistpolicies -u $user\"`;
	print "\n";
	print "$out\n";
	print "\n";

	my @pol_array = split("\n", $out);
	foreach my $line (@pol_array){
		if( $line =~/^(.+)/ ){
			my $this_pol = $1;
			print "Removing Policy " . $this_pol . " from User $user\n";
			if( remove_policy_in_user($account, $user, $this_pol) ){
				print "[TEST_REPORT]\tFAILED in removing policy $this_pol from user $user !!\n\n";
			};
		};
	};

	print "\n";
	print "########################### GET-ALL-POLICIES-IN-USER ##############################\n";

	### verify that policies have been cleared off
	print "$ENV{'QA_CLC_IP'} :: euare-userlistpolicies -u $user\n";
	my $out = `ssh -o ServerAliveInterval=1 -o ServerAliveCountMax=5 -o StrictHostKeyChecking=no root\@$ENV{'QA_CLC_IP'} \"source /root/cred_depot/$account/admin/eucarc; euare-userlistpolicies -u $user\"`;
	print "\n";
	print "$out\n";
	if( $out =~/^(.+)/m ){
		print "[TEST_REPORT]\tFAILED in removing all policies from user $user !!\n\n";
	};

	print "[TEST_REPORT]\tSucceeded in removing all policies from user $user\n\n";

	return 0;
};


sub remove_policy_in_user{
	my $account = shift @_;
	my $user = shift @_;
	my $policy = shift @_;

	print "\n";
	print "########################### REMOVE-POLICY-IN-USER ##############################\n";

        ### remove policy in user
        print "$ENV{'QA_CLC_IP'} :: euare-userdelpolicy -u $user -p $policy\n";
        system("ssh -o ServerAliveInterval=1 -o ServerAliveCountMax=5 -o StrictHostKeyChecking=no root\@$ENV{'QA_CLC_IP'} \"source /root/cred_depot/$account/admin/eucarc; euare-userdelpolicy -u $user -p $policy \" ");
        print "\n";

	### verify the removal
        print "$ENV{'QA_CLC_IP'} :: euare-userlistpolicies -u $user\n";
        my $out = `ssh -o ServerAliveInterval=1 -o ServerAliveCountMax=5 -o StrictHostKeyChecking=no root\@$ENV{'QA_CLC_IP'} \"source /root/cred_depot/$account/admin/eucarc; euare-userlistpolicies -u $user\" `;
        print "\n";
        print "$out\n";
        print "\n";

	if( $out =~ /^$policy$/m ){
		return 1;
	};

	return 0;
};

sub remove_all_accounts{

	print "\n";
	print "########################### GET-ALL-ACCOUNTS ##############################\n";

	### get all account
	print "$ENV{'QA_CLC_IP'} :: euare-accountlist\n";
	my $out = `ssh -o ServerAliveInterval=1 -o ServerAliveCountMax=5 -o StrictHostKeyChecking=no root\@$ENV{'QA_CLC_IP'} \"source /root/cred_depot/eucalyptus/admin/eucarc; euare-accountlist\"`;
	print "\n";
	print "$out\n";
	print "\n";

	my @acc_array = split("\n", $out);
	foreach my $line (@acc_array){
		if( $line =~/^(\S+)\s+\d+/ ){
			my $this_acc = $1;
			if( $this_acc ne "eucalyptus" ){
				print "Removing Account " . $this_acc . "\n";
				if( remove_account($this_acc) ){
					print "[TEST_REPORT]\tFAILED in removing account $this_acc !!\n\n";
				};
			};
		};
	};

	print "\n";
	print "########################### GET-ALL-ACCOUNTS ##############################\n";

	### verify that policies have been cleared off
	print "$ENV{'QA_CLC_IP'} :: euare-accountlist \n";
	my $out = `ssh -o ServerAliveInterval=1 -o ServerAliveCountMax=5 -o StrictHostKeyChecking=no root\@$ENV{'QA_CLC_IP'} \"source /root/cred_depot/eucalyptus/admin/eucarc; euare-accountlist\"`;
	print "\n";
	print "$out\n";
	if( $out =~/^(\S+)\s+\d+/m ){
		if( $1 ne "eucalyptus" ){
			print "[TEST_REPORT]\tFAILED in removing all accounts !!\n\n";
		};
	};

	print "[TEST_REPORT]\tSucceeded in removing all accounts \n\n";

	return 0;
};


sub remove_account{
	my $account = shift @_;

	print "\n";
	print "########################### REMOVE-ACCOUNT ##############################\n";

        ### remove account
        print "$ENV{'QA_CLC_IP'} :: euare-accountdel -a $account -r \n";
        system("ssh -o ServerAliveInterval=1 -o ServerAliveCountMax=5 -o StrictHostKeyChecking=no root\@$ENV{'QA_CLC_IP'} \"source /root/cred_depot/eucalyptus/admin/eucarc; euare-accountdel -a $account -r \" ");
        print "\n";

	### verify the removal
        print "$ENV{'QA_CLC_IP'} :: euare-accountlist \n";
        my $out = `ssh -o ServerAliveInterval=1 -o ServerAliveCountMax=5 -o StrictHostKeyChecking=no root\@$ENV{'QA_CLC_IP'} \"source /root/cred_depot/eucalyptus/admin/eucarc; euare-accountlist \" `;
        print "\n";
        print "$out\n";
        print "\n";

	if( $out =~ /^$account/m ){
		return 1;
	};

	return 0;
};


1;
