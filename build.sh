#!/bin/bash

yum install -y pcre-devel openssl-devel gcc curl

path=`pwd`

# install openssl
tar -zxvf openssl-1.1.1l.tar.gz

cd $path/openssl-1.1.1l

# openssl path
./config --prefix=/usr/local/openssl

# make and install
make && make install

cd $path && tar -zxvf openresty-ja3.tar.gz

cd $path/openresty-ja3

./configure --prefix=/usr/local/openresty \
            --with-luajit \
            --without-http_redis2_module \
            --with-http_iconv_module \
            --with-openssl=/usr/local/openssl

make && make install

cp $path/resty/ssl.lua /usr/local/openresty/lualib/resty/

echo "install openresty ssl ja3 succeed"
