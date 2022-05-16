local _M = {}

local base = require("resty.core.base")
local ffi = require('ffi')
local C = ffi.C
local ffi_str = ffi.string
local ffi_typeof = ffi.typeof
local ffi_cast = ffi.cast
local new_tab = require "table.new"
local ngx_md5 = ngx.md5

ffi.cdef[[
   typedef struct {
        int             version;
        size_t          ciphers_sz;
        unsigned short *ciphers;

        size_t          extensions_sz;
        unsigned short *extensions;

        size_t          curves_sz;
        unsigned short  *curves;

        size_t          point_formats_sz;
        unsigned char  *point_formats;

        ngx_str_t       cause;
        ngx_str_t       issuer;
        ngx_str_t       issuer_legacy;
        ngx_str_t       subject;
        ngx_str_t       subject_legacy;
        ngx_str_t       session;
        ngx_str_t       session_reused;
        ngx_str_t       protocol;
        ngx_str_t       curves_v;
        ngx_str_t       ciphers_v;
        ngx_str_t       cipher_name;
        ngx_str_t       server_name;
        ngx_str_t       fingerprint;
        ngx_str_t       serial_number;
        ngx_str_t       client_verify;
        ngx_str_t       client_start;
        ngx_str_t       client_end;
        ngx_str_t       client_remain;

        int             last;
        unsigned        in_ocsp:1;
        unsigned        handshaked:1;
        unsigned        renegotiation:1;
        unsigned        handshake_rejected:1;

    } ngx_ssl_ffi_ja3_t;

   ngx_ssl_ffi_ja3_t *ngx_http_lua_ffi_ssl_ja3(ngx_http_request_t *);
   ngx_str_t  ngx_http_lua_ffi_ssl_ja3_fp(ngx_http_request_t * , ngx_ssl_ffi_ja3_t *);

]]

--[[
    local ssl = require("resty.ssl")
    
    local ja3 = ssl.ja3()
    ja3.version
    ja3.ciphers
    ja3.session
    ja3.server_name
    ja3.fp
    ja3.fingerprint
    ja3.last
    ja3.handshake
]]

local function join(ptr , size)
    local len = tonumber(size)

    if len == 0 then
        return ""
    end
    
    local sum = ""

    local arr = new_tab( 0 , len * 2 - 1)
    local idx = 1
    for i = 0 , len - 1 do
        if i == 0 then
            sum = sum .. tonumber(ptr[i])
        else
            sum = sum .."-" .. tonumber(ptr[i])
        end
    end
    
    return sum
end

local function unpack(cdata) --cdata: ngx_str_t 
    return ffi_str(cdata.data , tonumber(cdata.len))
end

local function to_bool(cdata)
    return tonumber(cdata) == 1
end

function _M.ja3() 
    local r = base.get_request()
    local cdata = C.ngx_http_lua_ffi_ssl_ja3(r)
    
    if cdata == ngx.NULL then
        return nil
    end
    
    local fp = C.ngx_http_lua_ffi_ssl_ja3_fp(r , cdata)
    
    local fv = ffi_str(fp.data , fp.len)
    
    local hash = ngx_md5(fv)
    
    local ja3 = {
        last = tonumber(cdata.last),

        verion = tonumber(cdata.version),

        ciphers = join(cdata.ciphers , cdata.ciphers_sz),

        curves = join(cdata.curves , cdata.curves_sz),

        extensions = join(cdata.extensions, cdata.extensions_sz),

        point_formats = join(cdata.point_formats ,cdata.point_formats_sz),


        session = unpack(cdata.session),
        session_reused = unpack(cdata.session_reused),
    
        protocol = unpack(cdata.protocol),

        curves_raw = unpack(cdata.curves_v),
        ciphers_raw = unpack(cdata.ciphers_v),
        cipher_name = unpack(cdata.cipher_name),
    
        client_start = unpack(cdata.client_start),
        client_end = unpack(cdata.client_end),
        client_remain = unpack(cdata.client_remain),
 
        server = unpack(cdata.server_name),
        
        serial = unpack(cdata.serial_number),

        fp_raw = unpack(cdata.fingerprint),
        issuer_raw = unpack(cdata.issuer),
        issuer_legacy = unpack(cdata.issuer_legacy),

        subject = unpack(cdata.subject),
        subject_legacy = unpack(cdata.subject_legacy),
        
        
        handshaked =  to_bool(cdata.handshaked),

        renegotiation = to_bool(cdata.renegotiation),

        handshake_rejected =  to_bool(cdata.handshake_rejected),
    
        fp = fv,

        hash = hash,

        --cause = ffi_str(cdata.cause.data , tonumber(cdata.cause.len)),
    }

    
    return ja3

end

return _M
