@rem useful
@openssl speed -elapsed -evp aes-128-cbc
@openssl speed -elapsed -evp aes-256-cbc
@openssl speed -elapsed -evp aes-128-gcm
@openssl speed -elapsed -evp aes-256-gcm

@openssl speed -elapsed -evp sha1
@openssl speed -elapsed -evp sha256
@openssl speed -elapsed -evp sha512

@rem wireguard related
@openssl speed -elapsed -evp BLAKE2s256
@openssl speed -elapsed -evp BLAKE2b512
@openssl speed -elapsed -evp chacha20-poly1305

@rem ecdh and eddsa(ed25519,ed448)
@openssl speed -elapsed ecdh
@openssl speed -elapsed eddsa

