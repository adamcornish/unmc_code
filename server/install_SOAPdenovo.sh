mkdir SOAPdenovo
cd SOAPdenovo
wget http://soap.genomics.org.cn/down/SOAPdenovo-V1.05.src.tgz
tar zxvf SOAPdenovo-V1.05.src.tgz
cd SOAPdenovo-V1.05
make
cp bin/* /usr/local/bin
cd ../../
rm -fr SOAPdenovo
