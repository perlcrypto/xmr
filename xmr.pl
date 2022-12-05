=b
XMR
=cut
use warnings;
use strict;
use Parallel::ForkManager;
my $forkNo = 1;
my $pm = Parallel::ForkManager->new("$forkNo");

my $miner = "lolminer";# or lolminer

###main jobs to do
#my $killjobs = "yes";
my $sumitjobs = "yes";
my $killjobs = "no";
#my $sumitjobs = "no";
my $checkstatus = "yes";

my %nodes = (
    #161 => [0],#8..18,20..22,39..41],#[1,3,39..42],#1,3,39..
    #161 => [8..18],#8..18,20..22,39..41],#[1,3,39..42],#1,3,39..
    #161 => [10],#[1,3,39..42],#1,3,39.., bad node 18
    161 => [1,3,8..18,20..21,39..42],#[1,3,39..42],#1,3,39..    
    #161 => [17],#[1,3,39..42],#1,3,39..    
    182 => [7,20..24],
    190 => [1..3],
    );
#get current for the corresponding setting    
my $ip = `/usr/sbin/ip a`;    
$ip =~ /140\.117\.\d+\.(\d+)/;
my $cluster = $1;
$cluster =~ s/^\s+|\s+$//;
#print "\$cluster: $cluster\n";
my @allnodes = @{$nodes{$cluster}};#get node information
my @nodes;

#test whether the connection is ok
`touch ~/scptest.dat`;
for (@allnodes){
    my $nodeindex=sprintf("%02d",$_);
    my $nodename= "node"."$nodeindex";
    my $cmd = "/usr/bin/ssh $nodename ";
    print "****Check $nodename status\n ";
    #`echo "***$nodename" >> $output`;
#use scp for ssh test
	system("scp -o ConnectTimeout=5 ~/scptest.dat root\@$nodename:/root");    
    if($?){
		next;#not available
		}
	else{
		print "scp at $nodename ok for ssh test\n";
        push @nodes, $_;
		}	
}
chomp @nodes;
print @nodes. "\n";

`rm -f ./dupJobs.dat`;
`touch ./dupJobs.dat`;
for (@nodes){
$pm->start and next;
    my $nodeindex=sprintf("%02d",$_);
    my $nodename= "node"."$nodeindex";
    my $cmd = "/usr/bin/ssh $nodename ";
    my $mining_cmd;
    $mining_cmd = "nohup /home/jsp/xmrig-6.18.1/xmrig --coin=XMR -o 18.167.166.214:2222 \\
       -u 89g9n2yjhehJxhjLG9JTsP7smM9MnddbcgiEiCJ2bdyHGXGzsVZc9NpMSJpywd5kbY6zbogerdmpaVxiHpPuCioCSwGE8gS\.$nodename-$cluster -p x 2>&1 >/dev/null &";
#system("/home/jsp/xmrig-6.18.1/xmrig --coin=XMR -o 18.167.166.214:2222 -u 89g9n2yjhehJxhjLG9JTsP7smM9MnddbcgiEiCJ2bdyHGXGzsVZc9NpMSJpywd5kbY6zbogerdmpaVxiHpPuCioCSwGE8gS.RIG_ID -p x");
     my $temp = `$cmd "/usr/bin/ps aux|/usr/bin/grep -v grep|/usr/bin/egrep \\\"xmrig\\\""`;
    print "*****$nodename*****\n";
    print "###node status before all cmd:\n $temp\n";
    if($killjobs eq "yes"){
        print "#Want to kill job\n";
        if($temp){
            print "killing job\n";
            `$cmd "/usr/bin/ps aux|/usr/bin/grep -v grep|/usr/bin/egrep \\\"xmrig\\\"|awk '{print \\\$2}'|xargs kill"`;
        }
        else{
             print "No existing job currently!\n";
        }
    }

    if($sumitjobs eq "yes"){
        print "#Want to submit job\n";
        my $temp1 = `$cmd "/usr/bin/ps aux|/usr/bin/grep -v grep|/usr/bin/egrep \\\"xmrig\\\""`;
       
        unless($temp1){
            print "Submitting job\n";
            my $pid = fork();
		    if ($pid == 0) {
                exec("$cmd '$mining_cmd'");
                #$overclock{$1} only for windows
                }# if($pid == 0);
        }
        else{
            print "job already exists!\n";
        }
    }
    if($checkstatus eq "yes"){
        $temp = `$cmd "ps aux|grep -v grep|grep xmrig"`;
        print "#Want to check node current status\n";
        print "Checking status\n";
        print "output:$temp\n";
    }
$pm->finish;
}
$pm->wait_all_children;
system("ps aux|grep -v grep|grep 'ssh node'|grep jsp|awk '{print \$2}'|xargs kill");
sleep(1);
if($?) {print "$!\n";}
print "doing final grep check. If the following is empty, it is done.\n";
system("ps aux|grep -v grep|grep 'ssh node'|grep jsp");
