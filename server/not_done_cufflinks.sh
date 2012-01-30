mkdir cufflinks
cd cufflinks
svn co https://samtools.svn.sourceforge.net/svnroot/samtools/trunk/samtools
cd samtools
make
mkdir -p /usr/local/include/bam
cp samtools /usr/local/bin
cp libbam.a /usr/local/lib
cp *.h /usr/local/include/bam
cd ../
wget http://cufflinks.cbcb.umd.edu/downloads/cufflinks-1.0.2.tar.gz
tar zxvf cufflinks-1.0.2.tar.gz
cd cufflinks-1.0.2
./configure --with-boost=/usr/include/boost
make
make install
