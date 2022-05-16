# openresty ssl ja3
openresty ssl ja3 的指纹识别扩展

## 安装
```bash
    git clone https://github.com/vela-security/openresty-ssl-ja3.git

    cd openresty-ssl-ja3

    bash build.sh
```

## 配置 
```nginx
    listen       443 ssl;
    ssl_session_cache  shared:SSL:50m;
    ssl_session_timeout 30m;
    ssl_certificate        ssl.pem;
    ssl_certificate_key    ssl.key;
    access_by_lua_block {
        local ssl = require("resty.ssl")
        local cjson = require("cjson")
        ngx.header["Content-Type"] = "text/html"
        local ja3 = ssl.ja3()
        ja3.addr = ngx.var.remote_addr
        ngx.say(cjson.encode(ja3))
    }
```

## 说明
- openresty nginx 中有代码改动 主要包含 ngx_event_openssl.c 和 ngx_event_openssl.h
- openresty lua nginx 添加了 ngx_http_lua_ssl_ja3.c 和 ngx_http_lua_ssl_ja3.h
- openssl 添加了hello 包信息握手的回调函数

## 字段说名 
```json
    {
    "last": -2, // last time
    "verion": 771, //版本
    "ciphers": "4865-4866-4867-49195-49199-49196-49200-52393-52392-49171-49172-156-157-47-53",
    "client_start": "", //client_v_start
    "curves": "29-23-24", 
    "client_remain": "",
    "extensions": "23-65281-10-11-35-16-5-13-18-51-45-43-27-21",
    "point_formats": "0",
    "session": "",
    "session_reused": ".",
    "protocol": "TLSv1.2",
    "curves_raw": "0x7a7a:X25519:prime256v1:secp384r1",
    "issuer_legacy": "",
    "subject": "",
    "subject_legacy": "",
    "handshaked": true,
    "renegotiation": false,
    "handshake_rejected": false,
    "server": "",
    "ciphers_raw": "0x5a5a:TLS_AES_128_GCM_SHA256:TLS_AES_256_GCM_SHA384:TLS_CHACHA20_POLY1305_SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-RSA-AES128-SHA:ECDHE-RSA-AES256-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA:AES256-SHA",
    "issuer_raw": "",
    "fp_raw": "",
    "serial": "",
    "fp": "771,4865-4866-4867-49195-49199-49196-49200-52393-52392-49171-49172-156-157-47-53,23-65281-10-11-35-16-5-13-18-51-45-43-27-21,29-23-24,0", //指纹信息
    "cipher_name": "ECDHE-RSA-AES128-GCM-SHA256",
    "client_end": "",
    "hash": "b592adaa596bb72a5c1ccdbecae52e3f" //JA3指纹信息

}

```

## 参考
[https://github.com/fooinha/nginx-ssl-ja3](https://github.com/fooinha/nginx-ssl-ja3)