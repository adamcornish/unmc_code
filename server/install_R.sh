mkdir R_project
cd R_project
wget http://cran.opensourceresources.org/src/base/R-2/R-2.13.0.tar.gz
tar zxvf R-2.13.0.tar.gz
cd R-2.13.0
./configure
make
make all
cd ../../
rm -fr R_project
