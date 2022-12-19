system("yum -y groupinstall 'Development Tools'");
chdir("/root");
system("rm -rf redir");
system("yum install git -y");
system("git clone https://github.com/troglobit/redir.git");
chdir("/root/redir");
system("yum -y install automake");
system("yum -y install autoconf");
system("./autogen.sh");
system("./configure");#The default directory is /usr/local/bin/redir.  
system("make -j5");
system("make install-strip");
`ln -s /usr/local/bin/redir /usr/bin/redir`;
#usage:
#/usr/local/bin/redir :6542 us-eth.2miners.com:2020