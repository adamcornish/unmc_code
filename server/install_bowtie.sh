mkdir bowtie
cd bowtie
wget http://sourceforge.net/projects/bowtie-bio/files/bowtie/0.12.7/bowtie-0.12.7-src.zip/download
unzip bowtie-0.12.7-src.zip
cd bowtie-0.12.7
make
mv bowtie /usr/local/bin
mv bowtie-build /usr/local/bin
mv bowtie-inspect /usr/local/bin
cd ../../
rm -fr bowtie
