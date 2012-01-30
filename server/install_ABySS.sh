mkdir ABySS
cd ABySS
wget http://google-sparsehash.googlecode.com/files/sparsehash-1.10-1.noarch.rpm
rpm -i sparsehash-1.10-1.noarch.rpm
wget http://www.bcgsc.ca/downloads/abyss/abyss-1.2.7.tar.gz
tar zxvf abyss-1.2.7.tar.gz
cd abyss-1.2.7
yum -y install openmpi
./configure --with-mpi=/usr/lib64/openmpi
make
make install
cd ../../
rm -fr ABySS
