/**
 * Author......: See docs/credits.txt
 * License.....: MIT
 */

#define NEW_SIMD_CODE

#ifdef KERNEL_STATIC
#include M2S(INCLUDE_PATH/inc_vendor.h)
#include M2S(INCLUDE_PATH/inc_types.h)
#include M2S(INCLUDE_PATH/inc_platform.cl)
#include M2S(INCLUDE_PATH/inc_common.cl)
#include M2S(INCLUDE_PATH/inc_simd.cl)
#include M2S(INCLUDE_PATH/inc_hash_whirlpool.cl)
#include M2S(INCLUDE_PATH/inc_cipher_aes.cl)
#include M2S(INCLUDE_PATH/inc_cipher_twofish.cl)
#include M2S(INCLUDE_PATH/inc_cipher_serpent.cl)
#include M2S(INCLUDE_PATH/inc_cipher_camellia.cl)
#include M2S(INCLUDE_PATH/inc_cipher_kuznyechik.cl)
#endif

#define VC_DATA_LEN (448)
#define VC_SALT_LEN ( 64)

typedef struct vc
{
  u32 data_buf[VC_DATA_LEN / 4];
  u32 keyfile_buf16[16];
  u32 keyfile_buf32[32];
  u32 keyfile_enabled;
  u32 signature;

  keyboard_layout_mapping_t keyboard_layout_mapping_buf[256];
  int                       keyboard_layout_mapping_cnt;

  int pim_multi; // 2048 for boot (not SHA-512 or Whirlpool), 1000 for others
  int pim_start;
  int pim_stop;

} vc_t;

#ifdef KERNEL_STATIC
#include M2S(INCLUDE_PATH/inc_truecrypt_crc32.cl)
#include M2S(INCLUDE_PATH/inc_truecrypt_xts.cl)
#include M2S(INCLUDE_PATH/inc_veracrypt_xts.cl)
#include M2S(INCLUDE_PATH/inc_veracrypt_keyfile.cl)
#endif

typedef struct vc_tmp
{
  u32 ipad[16];
  u32 opad[16];

  u32 dgst[64];
  u32 out[64];

  u32 pim_key[64];
  int pim; // marker for cracked
  int pim_check; // marker for _extended kernel

} vc_tmp_t;

DECLSPEC int check_header_0512 (GLOBAL_AS const vc_t *esalt_bufs, GLOBAL_AS const kernel_param_t *kernel_param, GLOBAL_AS u32 *key, SHM_TYPE u32 *s_te0, SHM_TYPE u32 *s_te1, SHM_TYPE u32 *s_te2, SHM_TYPE u32 *s_te3, SHM_TYPE u32 *s_te4, SHM_TYPE u32 *s_td0, SHM_TYPE u32 *s_td1, SHM_TYPE u32 *s_td2, SHM_TYPE u32 *s_td3, SHM_TYPE u32 *s_td4)
{
  u32 key1[8];
  u32 key2[8];

  key1[0] = hc_swap32_S (key[ 0]);
  key1[1] = hc_swap32_S (key[ 1]);
  key1[2] = hc_swap32_S (key[ 2]);
  key1[3] = hc_swap32_S (key[ 3]);
  key1[4] = hc_swap32_S (key[ 4]);
  key1[5] = hc_swap32_S (key[ 5]);
  key1[6] = hc_swap32_S (key[ 6]);
  key1[7] = hc_swap32_S (key[ 7]);
  key2[0] = hc_swap32_S (key[ 8]);
  key2[1] = hc_swap32_S (key[ 9]);
  key2[2] = hc_swap32_S (key[10]);
  key2[3] = hc_swap32_S (key[11]);
  key2[4] = hc_swap32_S (key[12]);
  key2[5] = hc_swap32_S (key[13]);
  key2[6] = hc_swap32_S (key[14]);
  key2[7] = hc_swap32_S (key[15]);

  if (verify_header_serpent    (esalt_bufs[DIGESTS_OFFSET_HOST].data_buf, esalt_bufs[DIGESTS_OFFSET_HOST].signature, key1, key2) == 1) return 0;
  if (verify_header_twofish    (esalt_bufs[DIGESTS_OFFSET_HOST].data_buf, esalt_bufs[DIGESTS_OFFSET_HOST].signature, key1, key2) == 1) return 0;
  if (verify_header_camellia   (esalt_bufs[DIGESTS_OFFSET_HOST].data_buf, esalt_bufs[DIGESTS_OFFSET_HOST].signature, key1, key2) == 1) return 0;
  if (verify_header_kuznyechik (esalt_bufs[DIGESTS_OFFSET_HOST].data_buf, esalt_bufs[DIGESTS_OFFSET_HOST].signature, key1, key2) == 1) return 0;
  if (verify_header_aes        (esalt_bufs[DIGESTS_OFFSET_HOST].data_buf, esalt_bufs[DIGESTS_OFFSET_HOST].signature, key1, key2, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4) == 1) return 0;

  return -1;
}

DECLSPEC int check_header_1024 (GLOBAL_AS const vc_t *esalt_bufs, GLOBAL_AS const kernel_param_t *kernel_param, GLOBAL_AS u32 *key, SHM_TYPE u32 *s_te0, SHM_TYPE u32 *s_te1, SHM_TYPE u32 *s_te2, SHM_TYPE u32 *s_te3, SHM_TYPE u32 *s_te4, SHM_TYPE u32 *s_td0, SHM_TYPE u32 *s_td1, SHM_TYPE u32 *s_td2, SHM_TYPE u32 *s_td3, SHM_TYPE u32 *s_td4)
{
  u32 key1[8];
  u32 key2[8];
  u32 key3[8];
  u32 key4[8];

  key1[0] = hc_swap32_S (key[ 0]);
  key1[1] = hc_swap32_S (key[ 1]);
  key1[2] = hc_swap32_S (key[ 2]);
  key1[3] = hc_swap32_S (key[ 3]);
  key1[4] = hc_swap32_S (key[ 4]);
  key1[5] = hc_swap32_S (key[ 5]);
  key1[6] = hc_swap32_S (key[ 6]);
  key1[7] = hc_swap32_S (key[ 7]);
  key2[0] = hc_swap32_S (key[ 8]);
  key2[1] = hc_swap32_S (key[ 9]);
  key2[2] = hc_swap32_S (key[10]);
  key2[3] = hc_swap32_S (key[11]);
  key2[4] = hc_swap32_S (key[12]);
  key2[5] = hc_swap32_S (key[13]);
  key2[6] = hc_swap32_S (key[14]);
  key2[7] = hc_swap32_S (key[15]);
  key3[0] = hc_swap32_S (key[16]);
  key3[1] = hc_swap32_S (key[17]);
  key3[2] = hc_swap32_S (key[18]);
  key3[3] = hc_swap32_S (key[19]);
  key3[4] = hc_swap32_S (key[20]);
  key3[5] = hc_swap32_S (key[21]);
  key3[6] = hc_swap32_S (key[22]);
  key3[7] = hc_swap32_S (key[23]);
  key4[0] = hc_swap32_S (key[24]);
  key4[1] = hc_swap32_S (key[25]);
  key4[2] = hc_swap32_S (key[26]);
  key4[3] = hc_swap32_S (key[27]);
  key4[4] = hc_swap32_S (key[28]);
  key4[5] = hc_swap32_S (key[29]);
  key4[6] = hc_swap32_S (key[30]);
  key4[7] = hc_swap32_S (key[31]);

  if (verify_header_serpent_aes         (esalt_bufs[DIGESTS_OFFSET_HOST].data_buf, esalt_bufs[DIGESTS_OFFSET_HOST].signature, key1, key2, key3, key4, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4) == 1) return 0;
  if (verify_header_twofish_serpent     (esalt_bufs[DIGESTS_OFFSET_HOST].data_buf, esalt_bufs[DIGESTS_OFFSET_HOST].signature, key1, key2, key3, key4) == 1) return 0;
  if (verify_header_aes_twofish         (esalt_bufs[DIGESTS_OFFSET_HOST].data_buf, esalt_bufs[DIGESTS_OFFSET_HOST].signature, key1, key2, key3, key4, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4) == 1) return 0;
  if (verify_header_camellia_kuznyechik (esalt_bufs[DIGESTS_OFFSET_HOST].data_buf, esalt_bufs[DIGESTS_OFFSET_HOST].signature, key1, key2, key3, key4) == 1) return 0;
  if (verify_header_camellia_serpent    (esalt_bufs[DIGESTS_OFFSET_HOST].data_buf, esalt_bufs[DIGESTS_OFFSET_HOST].signature, key1, key2, key3, key4) == 1) return 0;
  if (verify_header_kuznyechik_twofish  (esalt_bufs[DIGESTS_OFFSET_HOST].data_buf, esalt_bufs[DIGESTS_OFFSET_HOST].signature, key1, key2, key3, key4) == 1) return 0;
  if (verify_header_kuznyechik_aes      (esalt_bufs[DIGESTS_OFFSET_HOST].data_buf, esalt_bufs[DIGESTS_OFFSET_HOST].signature, key1, key2, key3, key4, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4) == 1) return 0;

  return -1;
}

DECLSPEC int check_header_1536 (GLOBAL_AS const vc_t *esalt_bufs, GLOBAL_AS const kernel_param_t *kernel_param, GLOBAL_AS u32 *key, SHM_TYPE u32 *s_te0, SHM_TYPE u32 *s_te1, SHM_TYPE u32 *s_te2, SHM_TYPE u32 *s_te3, SHM_TYPE u32 *s_te4, SHM_TYPE u32 *s_td0, SHM_TYPE u32 *s_td1, SHM_TYPE u32 *s_td2, SHM_TYPE u32 *s_td3, SHM_TYPE u32 *s_td4)
{
  u32 key1[8];
  u32 key2[8];
  u32 key3[8];
  u32 key4[8];
  u32 key5[8];
  u32 key6[8];

  key1[0] = hc_swap32_S (key[ 0]);
  key1[1] = hc_swap32_S (key[ 1]);
  key1[2] = hc_swap32_S (key[ 2]);
  key1[3] = hc_swap32_S (key[ 3]);
  key1[4] = hc_swap32_S (key[ 4]);
  key1[5] = hc_swap32_S (key[ 5]);
  key1[6] = hc_swap32_S (key[ 6]);
  key1[7] = hc_swap32_S (key[ 7]);
  key2[0] = hc_swap32_S (key[ 8]);
  key2[1] = hc_swap32_S (key[ 9]);
  key2[2] = hc_swap32_S (key[10]);
  key2[3] = hc_swap32_S (key[11]);
  key2[4] = hc_swap32_S (key[12]);
  key2[5] = hc_swap32_S (key[13]);
  key2[6] = hc_swap32_S (key[14]);
  key2[7] = hc_swap32_S (key[15]);
  key3[0] = hc_swap32_S (key[16]);
  key3[1] = hc_swap32_S (key[17]);
  key3[2] = hc_swap32_S (key[18]);
  key3[3] = hc_swap32_S (key[19]);
  key3[4] = hc_swap32_S (key[20]);
  key3[5] = hc_swap32_S (key[21]);
  key3[6] = hc_swap32_S (key[22]);
  key3[7] = hc_swap32_S (key[23]);
  key4[0] = hc_swap32_S (key[24]);
  key4[1] = hc_swap32_S (key[25]);
  key4[2] = hc_swap32_S (key[26]);
  key4[3] = hc_swap32_S (key[27]);
  key4[4] = hc_swap32_S (key[28]);
  key4[5] = hc_swap32_S (key[29]);
  key4[6] = hc_swap32_S (key[30]);
  key4[7] = hc_swap32_S (key[31]);
  key5[0] = hc_swap32_S (key[32]);
  key5[1] = hc_swap32_S (key[33]);
  key5[2] = hc_swap32_S (key[34]);
  key5[3] = hc_swap32_S (key[35]);
  key5[4] = hc_swap32_S (key[36]);
  key5[5] = hc_swap32_S (key[37]);
  key5[6] = hc_swap32_S (key[38]);
  key5[7] = hc_swap32_S (key[39]);
  key6[0] = hc_swap32_S (key[40]);
  key6[1] = hc_swap32_S (key[41]);
  key6[2] = hc_swap32_S (key[42]);
  key6[3] = hc_swap32_S (key[43]);
  key6[4] = hc_swap32_S (key[44]);
  key6[5] = hc_swap32_S (key[45]);
  key6[6] = hc_swap32_S (key[46]);
  key6[7] = hc_swap32_S (key[47]);

  if (verify_header_serpent_twofish_aes         (esalt_bufs[DIGESTS_OFFSET_HOST].data_buf, esalt_bufs[DIGESTS_OFFSET_HOST].signature, key1, key2, key3, key4, key5, key6, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4) == 1) return 0;
  if (verify_header_kuznyechik_serpent_camellia (esalt_bufs[DIGESTS_OFFSET_HOST].data_buf, esalt_bufs[DIGESTS_OFFSET_HOST].signature, key1, key2, key3, key4, key5, key6) == 1) return 0;
  if (verify_header_aes_twofish_serpent         (esalt_bufs[DIGESTS_OFFSET_HOST].data_buf, esalt_bufs[DIGESTS_OFFSET_HOST].signature, key1, key2, key3, key4, key5, key6, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4) == 1) return 0;

  return -1;
}

DECLSPEC void hmac_whirlpool_run_V (PRIVATE_AS u32x *w0, PRIVATE_AS u32x *w1, PRIVATE_AS u32x *w2, PRIVATE_AS u32x *w3, PRIVATE_AS u32x *ipad, PRIVATE_AS u32x *opad, PRIVATE_AS u32x *digest, SHM_TYPE u64 *s_MT0, SHM_TYPE u64 *s_MT1, SHM_TYPE u64 *s_MT2, SHM_TYPE u64 *s_MT3, SHM_TYPE u64 *s_MT4, SHM_TYPE u64 *s_MT5, SHM_TYPE u64 *s_MT6, SHM_TYPE u64 *s_MT7)
{
  digest[ 0] = ipad[ 0];
  digest[ 1] = ipad[ 1];
  digest[ 2] = ipad[ 2];
  digest[ 3] = ipad[ 3];
  digest[ 4] = ipad[ 4];
  digest[ 5] = ipad[ 5];
  digest[ 6] = ipad[ 6];
  digest[ 7] = ipad[ 7];
  digest[ 8] = ipad[ 8];
  digest[ 9] = ipad[ 9];
  digest[10] = ipad[10];
  digest[11] = ipad[11];
  digest[12] = ipad[12];
  digest[13] = ipad[13];
  digest[14] = ipad[14];
  digest[15] = ipad[15];

  whirlpool_transform_vector (w0, w1, w2, w3, digest, s_MT0, s_MT1, s_MT2, s_MT3, s_MT4, s_MT5, s_MT6, s_MT7);

  w0[0] = 0x80000000;
  w0[1] = 0;
  w0[2] = 0;
  w0[3] = 0;
  w1[0] = 0;
  w1[1] = 0;
  w1[2] = 0;
  w1[3] = 0;
  w2[0] = 0;
  w2[1] = 0;
  w2[2] = 0;
  w2[3] = 0;
  w3[0] = 0;
  w3[1] = 0;
  w3[2] = 0;
  w3[3] = (64 + 64) * 8;

  whirlpool_transform_vector (w0, w1, w2, w3, digest, s_MT0, s_MT1, s_MT2, s_MT3, s_MT4, s_MT5, s_MT6, s_MT7);

  w0[0] = digest[ 0];
  w0[1] = digest[ 1];
  w0[2] = digest[ 2];
  w0[3] = digest[ 3];
  w1[0] = digest[ 4];
  w1[1] = digest[ 5];
  w1[2] = digest[ 6];
  w1[3] = digest[ 7];
  w2[0] = digest[ 8];
  w2[1] = digest[ 9];
  w2[2] = digest[10];
  w2[3] = digest[11];
  w3[0] = digest[12];
  w3[1] = digest[13];
  w3[2] = digest[14];
  w3[3] = digest[15];

  digest[ 0] = opad[ 0];
  digest[ 1] = opad[ 1];
  digest[ 2] = opad[ 2];
  digest[ 3] = opad[ 3];
  digest[ 4] = opad[ 4];
  digest[ 5] = opad[ 5];
  digest[ 6] = opad[ 6];
  digest[ 7] = opad[ 7];
  digest[ 8] = opad[ 8];
  digest[ 9] = opad[ 9];
  digest[10] = opad[10];
  digest[11] = opad[11];
  digest[12] = opad[12];
  digest[13] = opad[13];
  digest[14] = opad[14];
  digest[15] = opad[15];

  whirlpool_transform_vector (w0, w1, w2, w3, digest, s_MT0, s_MT1, s_MT2, s_MT3, s_MT4, s_MT5, s_MT6, s_MT7);

  w0[0] = 0x80000000;
  w0[1] = 0;
  w0[2] = 0;
  w0[3] = 0;
  w1[0] = 0;
  w1[1] = 0;
  w1[2] = 0;
  w1[3] = 0;
  w2[0] = 0;
  w2[1] = 0;
  w2[2] = 0;
  w2[3] = 0;
  w3[0] = 0;
  w3[1] = 0;
  w3[2] = 0;
  w3[3] = (64 + 64) * 8;

  whirlpool_transform_vector (w0, w1, w2, w3, digest, s_MT0, s_MT1, s_MT2, s_MT3, s_MT4, s_MT5, s_MT6, s_MT7);
}

KERNEL_FQ KERNEL_FA void m13733_init (KERN_ATTR_TMPS_ESALT (vc_tmp_t, vc_t))
{
  const u64 gid = get_global_id (0);
  const u64 lid = get_local_id (0);
  const u64 lsz = get_local_size (0);

  /**
   * keyboard layout shared
   */

  const int keyboard_layout_mapping_cnt = esalt_bufs[DIGESTS_OFFSET_HOST].keyboard_layout_mapping_cnt;

  LOCAL_VK keyboard_layout_mapping_t s_keyboard_layout_mapping_buf[256];

  for (u32 i = lid; i < 256; i += lsz)
  {
    s_keyboard_layout_mapping_buf[i] = esalt_bufs[DIGESTS_OFFSET_HOST].keyboard_layout_mapping_buf[i];
  }

  SYNC_THREADS ();

  /**
   * Whirlpool shared
   */

  #ifdef REAL_SHM

  LOCAL_VK u64 s_MT0[256];
  LOCAL_VK u64 s_MT1[256];
  LOCAL_VK u64 s_MT2[256];
  LOCAL_VK u64 s_MT3[256];
  LOCAL_VK u64 s_MT4[256];
  LOCAL_VK u64 s_MT5[256];
  LOCAL_VK u64 s_MT6[256];
  LOCAL_VK u64 s_MT7[256];

  for (u32 i = lid; i < 256; i += lsz)
  {
    s_MT0[i] = MT0[i];
    s_MT1[i] = MT1[i];
    s_MT2[i] = MT2[i];
    s_MT3[i] = MT3[i];
    s_MT4[i] = MT4[i];
    s_MT5[i] = MT5[i];
    s_MT6[i] = MT6[i];
    s_MT7[i] = MT7[i];
  }

  SYNC_THREADS ();

  #else

  CONSTANT_AS u64a *s_MT0 = MT0;
  CONSTANT_AS u64a *s_MT1 = MT1;
  CONSTANT_AS u64a *s_MT2 = MT2;
  CONSTANT_AS u64a *s_MT3 = MT3;
  CONSTANT_AS u64a *s_MT4 = MT4;
  CONSTANT_AS u64a *s_MT5 = MT5;
  CONSTANT_AS u64a *s_MT6 = MT6;
  CONSTANT_AS u64a *s_MT7 = MT7;

  #endif

  if (gid >= GID_CNT) return;

  /**
   * base
   */

  u32 w[32];

  w[ 0] = pws[gid].i[ 0];
  w[ 1] = pws[gid].i[ 1];
  w[ 2] = pws[gid].i[ 2];
  w[ 3] = pws[gid].i[ 3];
  w[ 4] = pws[gid].i[ 4];
  w[ 5] = pws[gid].i[ 5];
  w[ 6] = pws[gid].i[ 6];
  w[ 7] = pws[gid].i[ 7];
  w[ 8] = pws[gid].i[ 8];
  w[ 9] = pws[gid].i[ 9];
  w[10] = pws[gid].i[10];
  w[11] = pws[gid].i[11];
  w[12] = pws[gid].i[12];
  w[13] = pws[gid].i[13];
  w[14] = pws[gid].i[14];
  w[15] = pws[gid].i[15];
  w[16] = pws[gid].i[16];
  w[17] = pws[gid].i[17];
  w[18] = pws[gid].i[18];
  w[19] = pws[gid].i[19];
  w[20] = pws[gid].i[20];
  w[21] = pws[gid].i[21];
  w[22] = pws[gid].i[22];
  w[23] = pws[gid].i[23];
  w[24] = pws[gid].i[24];
  w[25] = pws[gid].i[25];
  w[26] = pws[gid].i[26];
  w[27] = pws[gid].i[27];
  w[28] = pws[gid].i[28];
  w[29] = pws[gid].i[29];
  w[30] = pws[gid].i[30];
  w[31] = pws[gid].i[31];

  u32 pw_len = pws[gid].pw_len;

  hc_execute_keyboard_layout_mapping (w, pw_len, s_keyboard_layout_mapping_buf, keyboard_layout_mapping_cnt);

  pw_len = hc_apply_keyfile_vc (w, pw_len, &esalt_bufs[DIGESTS_OFFSET_HOST]);

  whirlpool_hmac_ctx_t whirlpool_hmac_ctx;

  whirlpool_hmac_init_swap (&whirlpool_hmac_ctx, w, pw_len, s_MT0, s_MT1, s_MT2, s_MT3, s_MT4, s_MT5, s_MT6, s_MT7);

  tmps[gid].ipad[ 0] = whirlpool_hmac_ctx.ipad.h[ 0];
  tmps[gid].ipad[ 1] = whirlpool_hmac_ctx.ipad.h[ 1];
  tmps[gid].ipad[ 2] = whirlpool_hmac_ctx.ipad.h[ 2];
  tmps[gid].ipad[ 3] = whirlpool_hmac_ctx.ipad.h[ 3];
  tmps[gid].ipad[ 4] = whirlpool_hmac_ctx.ipad.h[ 4];
  tmps[gid].ipad[ 5] = whirlpool_hmac_ctx.ipad.h[ 5];
  tmps[gid].ipad[ 6] = whirlpool_hmac_ctx.ipad.h[ 6];
  tmps[gid].ipad[ 7] = whirlpool_hmac_ctx.ipad.h[ 7];
  tmps[gid].ipad[ 8] = whirlpool_hmac_ctx.ipad.h[ 8];
  tmps[gid].ipad[ 9] = whirlpool_hmac_ctx.ipad.h[ 9];
  tmps[gid].ipad[10] = whirlpool_hmac_ctx.ipad.h[10];
  tmps[gid].ipad[11] = whirlpool_hmac_ctx.ipad.h[11];
  tmps[gid].ipad[12] = whirlpool_hmac_ctx.ipad.h[12];
  tmps[gid].ipad[13] = whirlpool_hmac_ctx.ipad.h[13];
  tmps[gid].ipad[14] = whirlpool_hmac_ctx.ipad.h[14];
  tmps[gid].ipad[15] = whirlpool_hmac_ctx.ipad.h[15];

  tmps[gid].opad[ 0] = whirlpool_hmac_ctx.opad.h[ 0];
  tmps[gid].opad[ 1] = whirlpool_hmac_ctx.opad.h[ 1];
  tmps[gid].opad[ 2] = whirlpool_hmac_ctx.opad.h[ 2];
  tmps[gid].opad[ 3] = whirlpool_hmac_ctx.opad.h[ 3];
  tmps[gid].opad[ 4] = whirlpool_hmac_ctx.opad.h[ 4];
  tmps[gid].opad[ 5] = whirlpool_hmac_ctx.opad.h[ 5];
  tmps[gid].opad[ 6] = whirlpool_hmac_ctx.opad.h[ 6];
  tmps[gid].opad[ 7] = whirlpool_hmac_ctx.opad.h[ 7];
  tmps[gid].opad[ 8] = whirlpool_hmac_ctx.opad.h[ 8];
  tmps[gid].opad[ 9] = whirlpool_hmac_ctx.opad.h[ 9];
  tmps[gid].opad[10] = whirlpool_hmac_ctx.opad.h[10];
  tmps[gid].opad[11] = whirlpool_hmac_ctx.opad.h[11];
  tmps[gid].opad[12] = whirlpool_hmac_ctx.opad.h[12];
  tmps[gid].opad[13] = whirlpool_hmac_ctx.opad.h[13];
  tmps[gid].opad[14] = whirlpool_hmac_ctx.opad.h[14];
  tmps[gid].opad[15] = whirlpool_hmac_ctx.opad.h[15];

  whirlpool_hmac_update_global_swap (&whirlpool_hmac_ctx, salt_bufs[SALT_POS_HOST].salt_buf, VC_SALT_LEN);

  for (u32 i = 0, j = 1; i < 48; i += 16, j += 1)
  {
    whirlpool_hmac_ctx_t whirlpool_hmac_ctx2 = whirlpool_hmac_ctx;

    u32 w0[4];
    u32 w1[4];
    u32 w2[4];
    u32 w3[4];

    w0[0] = j;
    w0[1] = 0;
    w0[2] = 0;
    w0[3] = 0;
    w1[0] = 0;
    w1[1] = 0;
    w1[2] = 0;
    w1[3] = 0;
    w2[0] = 0;
    w2[1] = 0;
    w2[2] = 0;
    w2[3] = 0;
    w3[0] = 0;
    w3[1] = 0;
    w3[2] = 0;
    w3[3] = 0;

    whirlpool_hmac_update_64 (&whirlpool_hmac_ctx2, w0, w1, w2, w3, 4);

    whirlpool_hmac_final (&whirlpool_hmac_ctx2);

    tmps[gid].dgst[i +  0] = whirlpool_hmac_ctx2.opad.h[ 0];
    tmps[gid].dgst[i +  1] = whirlpool_hmac_ctx2.opad.h[ 1];
    tmps[gid].dgst[i +  2] = whirlpool_hmac_ctx2.opad.h[ 2];
    tmps[gid].dgst[i +  3] = whirlpool_hmac_ctx2.opad.h[ 3];
    tmps[gid].dgst[i +  4] = whirlpool_hmac_ctx2.opad.h[ 4];
    tmps[gid].dgst[i +  5] = whirlpool_hmac_ctx2.opad.h[ 5];
    tmps[gid].dgst[i +  6] = whirlpool_hmac_ctx2.opad.h[ 6];
    tmps[gid].dgst[i +  7] = whirlpool_hmac_ctx2.opad.h[ 7];
    tmps[gid].dgst[i +  8] = whirlpool_hmac_ctx2.opad.h[ 8];
    tmps[gid].dgst[i +  9] = whirlpool_hmac_ctx2.opad.h[ 9];
    tmps[gid].dgst[i + 10] = whirlpool_hmac_ctx2.opad.h[10];
    tmps[gid].dgst[i + 11] = whirlpool_hmac_ctx2.opad.h[11];
    tmps[gid].dgst[i + 12] = whirlpool_hmac_ctx2.opad.h[12];
    tmps[gid].dgst[i + 13] = whirlpool_hmac_ctx2.opad.h[13];
    tmps[gid].dgst[i + 14] = whirlpool_hmac_ctx2.opad.h[14];
    tmps[gid].dgst[i + 15] = whirlpool_hmac_ctx2.opad.h[15];

    tmps[gid].out[i +  0] = tmps[gid].dgst[i +  0];
    tmps[gid].out[i +  1] = tmps[gid].dgst[i +  1];
    tmps[gid].out[i +  2] = tmps[gid].dgst[i +  2];
    tmps[gid].out[i +  3] = tmps[gid].dgst[i +  3];
    tmps[gid].out[i +  4] = tmps[gid].dgst[i +  4];
    tmps[gid].out[i +  5] = tmps[gid].dgst[i +  5];
    tmps[gid].out[i +  6] = tmps[gid].dgst[i +  6];
    tmps[gid].out[i +  7] = tmps[gid].dgst[i +  7];
    tmps[gid].out[i +  8] = tmps[gid].dgst[i +  8];
    tmps[gid].out[i +  9] = tmps[gid].dgst[i +  9];
    tmps[gid].out[i + 10] = tmps[gid].dgst[i + 10];
    tmps[gid].out[i + 11] = tmps[gid].dgst[i + 11];
    tmps[gid].out[i + 12] = tmps[gid].dgst[i + 12];
    tmps[gid].out[i + 13] = tmps[gid].dgst[i + 13];
    tmps[gid].out[i + 14] = tmps[gid].dgst[i + 14];
    tmps[gid].out[i + 15] = tmps[gid].dgst[i + 15];
  }
}

KERNEL_FQ KERNEL_FA void m13733_loop (KERN_ATTR_TMPS_ESALT (vc_tmp_t, vc_t))
{
  const u64 gid = get_global_id (0);
  const u64 lid = get_local_id (0);
  const u64 lsz = get_local_size (0);

  /**
   * Whirlpool shared
   */

  #ifdef REAL_SHM

  LOCAL_VK u64 s_MT0[256];
  LOCAL_VK u64 s_MT1[256];
  LOCAL_VK u64 s_MT2[256];
  LOCAL_VK u64 s_MT3[256];
  LOCAL_VK u64 s_MT4[256];
  LOCAL_VK u64 s_MT5[256];
  LOCAL_VK u64 s_MT6[256];
  LOCAL_VK u64 s_MT7[256];

  for (u32 i = lid; i < 256; i += lsz)
  {
    s_MT0[i] = MT0[i];
    s_MT1[i] = MT1[i];
    s_MT2[i] = MT2[i];
    s_MT3[i] = MT3[i];
    s_MT4[i] = MT4[i];
    s_MT5[i] = MT5[i];
    s_MT6[i] = MT6[i];
    s_MT7[i] = MT7[i];
  }

  SYNC_THREADS ();

  #else

  CONSTANT_AS u64a *s_MT0 = MT0;
  CONSTANT_AS u64a *s_MT1 = MT1;
  CONSTANT_AS u64a *s_MT2 = MT2;
  CONSTANT_AS u64a *s_MT3 = MT3;
  CONSTANT_AS u64a *s_MT4 = MT4;
  CONSTANT_AS u64a *s_MT5 = MT5;
  CONSTANT_AS u64a *s_MT6 = MT6;
  CONSTANT_AS u64a *s_MT7 = MT7;

  #endif

  if (gid >= GID_CNT) return;

  // this is the pim range check
  // it is guaranteed that only 0 or 1 innerloops will match a "pim" mark (each 1000 iterations)
  // therefore the module limits the inner loop iteration count to 1000
  // if the key_pim is set, we know that we have to save and check the key for this pim

  const int pim_multi = esalt_bufs[DIGESTS_OFFSET_HOST].pim_multi;
  const int pim_start = esalt_bufs[DIGESTS_OFFSET_HOST].pim_start;
  const int pim_stop  = esalt_bufs[DIGESTS_OFFSET_HOST].pim_stop;

  int pim    = 0;
  int pim_at = 0;

  for (u32 j = 0; j < LOOP_CNT; j++)
  {
    const int iter_abs = 1 + LOOP_POS + j;

    if ((iter_abs % pim_multi) == pim_multi - 1)
    {
      const int pim_cur = (iter_abs / pim_multi) + 1;

      if ((pim_cur >= pim_start) && (pim_cur <= pim_stop))
      {
        pim = pim_cur;

        pim_at = j;
      }
    }
  }

  // irregular pbkdf2 from here

  u32x ipad[16];
  u32x opad[16];

  ipad[ 0] = packv (tmps, ipad, gid,  0);
  ipad[ 1] = packv (tmps, ipad, gid,  1);
  ipad[ 2] = packv (tmps, ipad, gid,  2);
  ipad[ 3] = packv (tmps, ipad, gid,  3);
  ipad[ 4] = packv (tmps, ipad, gid,  4);
  ipad[ 5] = packv (tmps, ipad, gid,  5);
  ipad[ 6] = packv (tmps, ipad, gid,  6);
  ipad[ 7] = packv (tmps, ipad, gid,  7);
  ipad[ 8] = packv (tmps, ipad, gid,  8);
  ipad[ 9] = packv (tmps, ipad, gid,  9);
  ipad[10] = packv (tmps, ipad, gid, 10);
  ipad[11] = packv (tmps, ipad, gid, 11);
  ipad[12] = packv (tmps, ipad, gid, 12);
  ipad[13] = packv (tmps, ipad, gid, 13);
  ipad[14] = packv (tmps, ipad, gid, 14);
  ipad[15] = packv (tmps, ipad, gid, 15);

  opad[ 0] = packv (tmps, opad, gid,  0);
  opad[ 1] = packv (tmps, opad, gid,  1);
  opad[ 2] = packv (tmps, opad, gid,  2);
  opad[ 3] = packv (tmps, opad, gid,  3);
  opad[ 4] = packv (tmps, opad, gid,  4);
  opad[ 5] = packv (tmps, opad, gid,  5);
  opad[ 6] = packv (tmps, opad, gid,  6);
  opad[ 7] = packv (tmps, opad, gid,  7);
  opad[ 8] = packv (tmps, opad, gid,  8);
  opad[ 9] = packv (tmps, opad, gid,  9);
  opad[10] = packv (tmps, opad, gid, 10);
  opad[11] = packv (tmps, opad, gid, 11);
  opad[12] = packv (tmps, opad, gid, 12);
  opad[13] = packv (tmps, opad, gid, 13);
  opad[14] = packv (tmps, opad, gid, 14);
  opad[15] = packv (tmps, opad, gid, 15);

  for (u32 i = 0; i < 48; i += 16)
  {
    u32x dgst[16];
    u32x out[16];

    dgst[ 0] = packv (tmps, dgst, gid, i +  0);
    dgst[ 1] = packv (tmps, dgst, gid, i +  1);
    dgst[ 2] = packv (tmps, dgst, gid, i +  2);
    dgst[ 3] = packv (tmps, dgst, gid, i +  3);
    dgst[ 4] = packv (tmps, dgst, gid, i +  4);
    dgst[ 5] = packv (tmps, dgst, gid, i +  5);
    dgst[ 6] = packv (tmps, dgst, gid, i +  6);
    dgst[ 7] = packv (tmps, dgst, gid, i +  7);
    dgst[ 8] = packv (tmps, dgst, gid, i +  8);
    dgst[ 9] = packv (tmps, dgst, gid, i +  9);
    dgst[10] = packv (tmps, dgst, gid, i + 10);
    dgst[11] = packv (tmps, dgst, gid, i + 11);
    dgst[12] = packv (tmps, dgst, gid, i + 12);
    dgst[13] = packv (tmps, dgst, gid, i + 13);
    dgst[14] = packv (tmps, dgst, gid, i + 14);
    dgst[15] = packv (tmps, dgst, gid, i + 15);

    out[ 0] = packv (tmps, out, gid, i +  0);
    out[ 1] = packv (tmps, out, gid, i +  1);
    out[ 2] = packv (tmps, out, gid, i +  2);
    out[ 3] = packv (tmps, out, gid, i +  3);
    out[ 4] = packv (tmps, out, gid, i +  4);
    out[ 5] = packv (tmps, out, gid, i +  5);
    out[ 6] = packv (tmps, out, gid, i +  6);
    out[ 7] = packv (tmps, out, gid, i +  7);
    out[ 8] = packv (tmps, out, gid, i +  8);
    out[ 9] = packv (tmps, out, gid, i +  9);
    out[10] = packv (tmps, out, gid, i + 10);
    out[11] = packv (tmps, out, gid, i + 11);
    out[12] = packv (tmps, out, gid, i + 12);
    out[13] = packv (tmps, out, gid, i + 13);
    out[14] = packv (tmps, out, gid, i + 14);
    out[15] = packv (tmps, out, gid, i + 15);

    for (u32 j = 0; j < LOOP_CNT; j++)
    {
      u32x w0[4];
      u32x w1[4];
      u32x w2[4];
      u32x w3[4];

      w0[0] = dgst[ 0];
      w0[1] = dgst[ 1];
      w0[2] = dgst[ 2];
      w0[3] = dgst[ 3];
      w1[0] = dgst[ 4];
      w1[1] = dgst[ 5];
      w1[2] = dgst[ 6];
      w1[3] = dgst[ 7];
      w2[0] = dgst[ 8];
      w2[1] = dgst[ 9];
      w2[2] = dgst[10];
      w2[3] = dgst[11];
      w3[0] = dgst[12];
      w3[1] = dgst[13];
      w3[2] = dgst[14];
      w3[3] = dgst[15];

      hmac_whirlpool_run_V (w0, w1, w2, w3, ipad, opad, dgst, s_MT0, s_MT1, s_MT2, s_MT3, s_MT4, s_MT5, s_MT6, s_MT7);

      out[ 0] ^= dgst[ 0];
      out[ 1] ^= dgst[ 1];
      out[ 2] ^= dgst[ 2];
      out[ 3] ^= dgst[ 3];
      out[ 4] ^= dgst[ 4];
      out[ 5] ^= dgst[ 5];
      out[ 6] ^= dgst[ 6];
      out[ 7] ^= dgst[ 7];
      out[ 8] ^= dgst[ 8];
      out[ 9] ^= dgst[ 9];
      out[10] ^= dgst[10];
      out[11] ^= dgst[11];
      out[12] ^= dgst[12];
      out[13] ^= dgst[13];
      out[14] ^= dgst[14];
      out[15] ^= dgst[15];

      // this iteration creates a valid pim

      if (j == pim_at)
      {
        unpackv (tmps, pim_key, gid, i +  0, out[ 0]);
        unpackv (tmps, pim_key, gid, i +  1, out[ 1]);
        unpackv (tmps, pim_key, gid, i +  2, out[ 2]);
        unpackv (tmps, pim_key, gid, i +  3, out[ 3]);
        unpackv (tmps, pim_key, gid, i +  4, out[ 4]);
        unpackv (tmps, pim_key, gid, i +  5, out[ 5]);
        unpackv (tmps, pim_key, gid, i +  6, out[ 6]);
        unpackv (tmps, pim_key, gid, i +  7, out[ 7]);
        unpackv (tmps, pim_key, gid, i +  8, out[ 8]);
        unpackv (tmps, pim_key, gid, i +  9, out[ 9]);
        unpackv (tmps, pim_key, gid, i + 10, out[10]);
        unpackv (tmps, pim_key, gid, i + 11, out[11]);
        unpackv (tmps, pim_key, gid, i + 12, out[12]);
        unpackv (tmps, pim_key, gid, i + 13, out[13]);
        unpackv (tmps, pim_key, gid, i + 14, out[14]);
        unpackv (tmps, pim_key, gid, i + 15, out[15]);

        const u32x pimx = make_u32x (pim);

        unpack (tmps, pim_check, gid, pimx);
      }
    }

    unpackv (tmps, dgst, gid, i +  0, dgst[ 0]);
    unpackv (tmps, dgst, gid, i +  1, dgst[ 1]);
    unpackv (tmps, dgst, gid, i +  2, dgst[ 2]);
    unpackv (tmps, dgst, gid, i +  3, dgst[ 3]);
    unpackv (tmps, dgst, gid, i +  4, dgst[ 4]);
    unpackv (tmps, dgst, gid, i +  5, dgst[ 5]);
    unpackv (tmps, dgst, gid, i +  6, dgst[ 6]);
    unpackv (tmps, dgst, gid, i +  7, dgst[ 7]);
    unpackv (tmps, dgst, gid, i +  8, dgst[ 8]);
    unpackv (tmps, dgst, gid, i +  9, dgst[ 9]);
    unpackv (tmps, dgst, gid, i + 10, dgst[10]);
    unpackv (tmps, dgst, gid, i + 11, dgst[11]);
    unpackv (tmps, dgst, gid, i + 12, dgst[12]);
    unpackv (tmps, dgst, gid, i + 13, dgst[13]);
    unpackv (tmps, dgst, gid, i + 14, dgst[14]);
    unpackv (tmps, dgst, gid, i + 15, dgst[15]);

    unpackv (tmps, out, gid, i +  0, out[ 0]);
    unpackv (tmps, out, gid, i +  1, out[ 1]);
    unpackv (tmps, out, gid, i +  2, out[ 2]);
    unpackv (tmps, out, gid, i +  3, out[ 3]);
    unpackv (tmps, out, gid, i +  4, out[ 4]);
    unpackv (tmps, out, gid, i +  5, out[ 5]);
    unpackv (tmps, out, gid, i +  6, out[ 6]);
    unpackv (tmps, out, gid, i +  7, out[ 7]);
    unpackv (tmps, out, gid, i +  8, out[ 8]);
    unpackv (tmps, out, gid, i +  9, out[ 9]);
    unpackv (tmps, out, gid, i + 10, out[10]);
    unpackv (tmps, out, gid, i + 11, out[11]);
    unpackv (tmps, out, gid, i + 12, out[12]);
    unpackv (tmps, out, gid, i + 13, out[13]);
    unpackv (tmps, out, gid, i + 14, out[14]);
    unpackv (tmps, out, gid, i + 15, out[15]);
  }
}

KERNEL_FQ KERNEL_FA void m13733_loop_extended (KERN_ATTR_TMPS_ESALT (vc_tmp_t, vc_t))
{
  const u64 gid = get_global_id (0);
  const u64 lid = get_local_id (0);
  const u64 lsz = get_local_size (0);

  /**
   * aes shared
   */

  #ifdef REAL_SHM

  LOCAL_VK u32 s_td0[256];
  LOCAL_VK u32 s_td1[256];
  LOCAL_VK u32 s_td2[256];
  LOCAL_VK u32 s_td3[256];
  LOCAL_VK u32 s_td4[256];

  LOCAL_VK u32 s_te0[256];
  LOCAL_VK u32 s_te1[256];
  LOCAL_VK u32 s_te2[256];
  LOCAL_VK u32 s_te3[256];
  LOCAL_VK u32 s_te4[256];

  for (u32 i = lid; i < 256; i += lsz)
  {
    s_td0[i] = td0[i];
    s_td1[i] = td1[i];
    s_td2[i] = td2[i];
    s_td3[i] = td3[i];
    s_td4[i] = td4[i];

    s_te0[i] = te0[i];
    s_te1[i] = te1[i];
    s_te2[i] = te2[i];
    s_te3[i] = te3[i];
    s_te4[i] = te4[i];
  }

  SYNC_THREADS ();

  #else

  CONSTANT_AS u32a *s_td0 = td0;
  CONSTANT_AS u32a *s_td1 = td1;
  CONSTANT_AS u32a *s_td2 = td2;
  CONSTANT_AS u32a *s_td3 = td3;
  CONSTANT_AS u32a *s_td4 = td4;

  CONSTANT_AS u32a *s_te0 = te0;
  CONSTANT_AS u32a *s_te1 = te1;
  CONSTANT_AS u32a *s_te2 = te2;
  CONSTANT_AS u32a *s_te3 = te3;
  CONSTANT_AS u32a *s_te4 = te4;

  #endif

  if (gid >= GID_CNT) return;

  const u32 pim_check = tmps[gid].pim_check;

  if (pim_check)
  {
    if (check_header_0512 (esalt_bufs, kernel_param, tmps[gid].pim_key, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4) != -1)
    {
      tmps[gid].pim = pim_check;
    }

    if (check_header_1024 (esalt_bufs, kernel_param, tmps[gid].pim_key, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4) != -1)
    {
      tmps[gid].pim = pim_check;
    }

    if (check_header_1536 (esalt_bufs, kernel_param, tmps[gid].pim_key, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4) != -1)
    {
      tmps[gid].pim = pim_check;
    }

    tmps[gid].pim_check = 0;
  }
}

KERNEL_FQ KERNEL_FA void m13733_comp (KERN_ATTR_TMPS_ESALT (vc_tmp_t, vc_t))
{
  const u64 gid = get_global_id (0);
  const u64 lid = get_local_id (0);
  const u64 lsz = get_local_size (0);

  /**
   * aes shared
   */

  #ifdef REAL_SHM

  LOCAL_VK u32 s_td0[256];
  LOCAL_VK u32 s_td1[256];
  LOCAL_VK u32 s_td2[256];
  LOCAL_VK u32 s_td3[256];
  LOCAL_VK u32 s_td4[256];

  LOCAL_VK u32 s_te0[256];
  LOCAL_VK u32 s_te1[256];
  LOCAL_VK u32 s_te2[256];
  LOCAL_VK u32 s_te3[256];
  LOCAL_VK u32 s_te4[256];

  for (u32 i = lid; i < 256; i += lsz)
  {
    s_td0[i] = td0[i];
    s_td1[i] = td1[i];
    s_td2[i] = td2[i];
    s_td3[i] = td3[i];
    s_td4[i] = td4[i];

    s_te0[i] = te0[i];
    s_te1[i] = te1[i];
    s_te2[i] = te2[i];
    s_te3[i] = te3[i];
    s_te4[i] = te4[i];
  }

  SYNC_THREADS ();

  #else

  CONSTANT_AS u32a *s_td0 = td0;
  CONSTANT_AS u32a *s_td1 = td1;
  CONSTANT_AS u32a *s_td2 = td2;
  CONSTANT_AS u32a *s_td3 = td3;
  CONSTANT_AS u32a *s_td4 = td4;

  CONSTANT_AS u32a *s_te0 = te0;
  CONSTANT_AS u32a *s_te1 = te1;
  CONSTANT_AS u32a *s_te2 = te2;
  CONSTANT_AS u32a *s_te3 = te3;
  CONSTANT_AS u32a *s_te4 = te4;

  #endif

  if (gid >= GID_CNT) return;

  if (tmps[gid].pim)
  {
    if (hc_atomic_inc (&hashes_shown[DIGESTS_OFFSET_HOST]) == 0)
    {
      mark_hash (plains_buf, d_return_buf, SALT_POS_HOST, DIGESTS_CNT, 0, DIGESTS_OFFSET_HOST + 0, gid, 0, 0, 0);
    }
  }
  else
  {
    if (check_header_0512 (esalt_bufs, kernel_param, tmps[gid].out, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4) != -1)
    {
      if (hc_atomic_inc (&hashes_shown[DIGESTS_OFFSET_HOST]) == 0)
      {
        mark_hash (plains_buf, d_return_buf, SALT_POS_HOST, DIGESTS_CNT, 0, DIGESTS_OFFSET_HOST + 0, gid, 0, 0, 0);
      }
    }

    if (check_header_1024 (esalt_bufs, kernel_param, tmps[gid].out, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4) != -1)
    {
      if (hc_atomic_inc (&hashes_shown[DIGESTS_OFFSET_HOST]) == 0)
      {
        mark_hash (plains_buf, d_return_buf, SALT_POS_HOST, DIGESTS_CNT, 0, DIGESTS_OFFSET_HOST + 0, gid, 0, 0, 0);
      }
    }

    if (check_header_1536 (esalt_bufs, kernel_param, tmps[gid].out, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4) != -1)
    {
      if (hc_atomic_inc (&hashes_shown[DIGESTS_OFFSET_HOST]) == 0)
      {
        mark_hash (plains_buf, d_return_buf, SALT_POS_HOST, DIGESTS_CNT, 0, DIGESTS_OFFSET_HOST + 0, gid, 0, 0, 0);
      }
    }
  }
}
