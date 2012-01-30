mkdir tophat
cd tophat
svn co https://samtools.svn.sourceforge.net/svnroot/samtools/trunk/samtools
cd samtools
make
mkdir -p include/bam/
mkdir lib
cp *.h include/bam/
cp libbam.a lib
cd ../
wget http://tophat.cbcb.umd.edu/downloads/tophat-1.1.4.tar.gz
tar zxvf tophat-1.1.4.tar.gz
cd tophat-1.1.4
cd ..
path=`pwd`
cd tophat-1.1.4
./configure --with-bam=$path/samtools
make
make install
cd ../../
rm -fr tophat
