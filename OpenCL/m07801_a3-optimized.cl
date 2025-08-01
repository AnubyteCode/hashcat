/**
 * Author......: See docs/credits.txt
 * License.....: MIT
 */

//incompatible data-dependant code
//#define NEW_SIMD_CODE

#ifdef KERNEL_STATIC
#include M2S(INCLUDE_PATH/inc_vendor.h)
#include M2S(INCLUDE_PATH/inc_types.h)
#include M2S(INCLUDE_PATH/inc_platform.cl)
#include M2S(INCLUDE_PATH/inc_common.cl)
#include M2S(INCLUDE_PATH/inc_simd.cl)
#include M2S(INCLUDE_PATH/inc_hash_sha1.cl)
#endif

CONSTANT_VK u32a theMagicArray[64] =
{
  0x91ac5114, 0x9f675443, 0x24e73be0, 0x28747bc2, 0x863313eb, 0x5a4fcb5c, 0x080a7337, 0x0e5d1c2f,
  0x338fe6e5, 0xf89baedd, 0x16f24b8d, 0x2ce1d4dc, 0xb0cbdf9d, 0xd4706d17, 0xf94d423f, 0x9b1b1194,
  0x9f5bc19b, 0x06059d03, 0x9d5e138a, 0x1e9a6ae8, 0xd97c1417, 0x58c72af6, 0xa199630a, 0xd7fd70c3,
  0xf65e7413, 0x03c90b04, 0x2698f726, 0x8a929325, 0xb0a20d23, 0xed63796d, 0x1332fa3c, 0x35029aa3,
  0xb3dd8e0a, 0x24bf51c3, 0x7ccd559f, 0x37af944c, 0x29085282, 0xb23b4e37, 0x9f170791, 0x113bfdcd,
  0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000,
  0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000,
  0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000,
};

DECLSPEC u32 GETSHIFTEDINT_CONST (CONSTANT_AS u32a *a, const int n)
{
  const int d = n / 4;
  const int m = n & 3;

  u64 tmp = hl32_to_64_S (a[d + 0], a[d + 1]);

  tmp <<= m * 8;

  return h32_from_64_S (tmp);
}

DECLSPEC void SETSHIFTEDINT (PRIVATE_AS u32 *a, const int n, const u32 v)
{
  const int d = n / 4;
  const int m = n & 3;

  u64 tmp = hl32_to_64_S (v, 0);

  tmp >>= m * 8;

  a[d + 0] |= h32_from_64_S (tmp);
  a[d + 1]  = l32_from_64_S (tmp);
}

DECLSPEC void m07801m (PRIVATE_AS u32 *w0, PRIVATE_AS u32 *w1, PRIVATE_AS u32 *w2, PRIVATE_AS u32 *w3, const u32 pw_len, KERN_ATTR_FUNC_BASIC ())
{
  /**
   * modifiers are taken from args
   */

  /**
   * salt
   */

  u32 salt_buf[4];

  salt_buf[0] = hc_swap32_S (salt_bufs[SALT_POS_HOST].salt_buf[0]);
  salt_buf[1] = hc_swap32_S (salt_bufs[SALT_POS_HOST].salt_buf[1]);
  salt_buf[2] = hc_swap32_S (salt_bufs[SALT_POS_HOST].salt_buf[2]);
  salt_buf[3] = hc_swap32_S (salt_bufs[SALT_POS_HOST].salt_buf[3]);

  const u32 salt_len = salt_bufs[SALT_POS_HOST].salt_len;

  u32 s0[4];
  u32 s1[4];
  u32 s2[4];
  u32 s3[4];

  s0[0] = salt_buf[0];
  s0[1] = salt_buf[1];
  s0[2] = salt_buf[2];
  s0[3] = salt_buf[3];
  s1[0] = 0;
  s1[1] = 0;
  s1[2] = 0;
  s1[3] = 0;
  s2[0] = 0;
  s2[1] = 0;
  s2[2] = 0;
  s2[3] = 0;
  s3[0] = 0;
  s3[1] = 0;
  s3[2] = 0;
  s3[3] = 0;

  switch_buffer_by_offset_be_S (s0, s1, s2, s3, pw_len);

  const u32x pw_salt_len = pw_len + salt_len;

  /**
   * loop
   */

  u32 w0l = w0[0];

  for (u32 il_pos = 0; il_pos < IL_CNT; il_pos += VECT_SIZE)
  {
    const u32x w0r = ix_create_bft (bfs_buf, il_pos);

    const u32x w0lr = w0l | w0r;

    w0[0] = w0lr;

    /**
     * SAP
     */

    u32 final[32];

    final[ 0] = w0[0] | s0[0];
    final[ 1] = w0[1] | s0[1];
    final[ 2] = w0[2] | s0[2];
    final[ 3] = w0[3] | s0[3];
    final[ 4] = w1[0] | s1[0];
    final[ 5] = w1[1] | s1[1];
    final[ 6] = w1[2] | s1[2];
    final[ 7] = w1[3] | s1[3];
    final[ 8] = w2[0] | s2[0];
    final[ 9] = w2[1] | s2[1];
    final[10] = w2[2] | s2[2];
    final[11] = w2[3] | s2[3];
    final[12] = w3[0] | s3[0];
    final[13] = w3[1] | s3[1];
    final[14] = 0;
    final[15] = pw_salt_len * 8;
    final[16] = 0;
    final[17] = 0;
    final[18] = 0;
    final[19] = 0;
    final[20] = 0;
    final[21] = 0;
    final[22] = 0;
    final[23] = 0;
    final[24] = 0;
    final[25] = 0;
    final[26] = 0;
    final[27] = 0;
    final[28] = 0;
    final[29] = 0;
    final[30] = 0;
    final[31] = 0;

    u32 digest[5];

    digest[0] = SHA1M_A;
    digest[1] = SHA1M_B;
    digest[2] = SHA1M_C;
    digest[3] = SHA1M_D;
    digest[4] = SHA1M_E;

    sha1_transform (final +  0, final +  4, final +  8, final + 12, digest);

    // prepare magic array range

    u32 lengthMagicArray = 0x20;
    u32 offsetMagicArray = 0;

    lengthMagicArray += unpack_v8d_from_v32_S (digest[0]) % 6;
    lengthMagicArray += unpack_v8c_from_v32_S (digest[0]) % 6;
    lengthMagicArray += unpack_v8b_from_v32_S (digest[0]) % 6;
    lengthMagicArray += unpack_v8a_from_v32_S (digest[0]) % 6;
    lengthMagicArray += unpack_v8d_from_v32_S (digest[1]) % 6;
    lengthMagicArray += unpack_v8c_from_v32_S (digest[1]) % 6;
    lengthMagicArray += unpack_v8b_from_v32_S (digest[1]) % 6;
    lengthMagicArray += unpack_v8a_from_v32_S (digest[1]) % 6;
    lengthMagicArray += unpack_v8d_from_v32_S (digest[2]) % 6;
    lengthMagicArray += unpack_v8c_from_v32_S (digest[2]) % 6;
    offsetMagicArray += unpack_v8b_from_v32_S (digest[2]) & 7;
    offsetMagicArray += unpack_v8a_from_v32_S (digest[2]) & 7;
    offsetMagicArray += unpack_v8d_from_v32_S (digest[3]) & 7;
    offsetMagicArray += unpack_v8c_from_v32_S (digest[3]) & 7;
    offsetMagicArray += unpack_v8b_from_v32_S (digest[3]) & 7;
    offsetMagicArray += unpack_v8a_from_v32_S (digest[3]) & 7;
    offsetMagicArray += unpack_v8d_from_v32_S (digest[4]) & 7;
    offsetMagicArray += unpack_v8c_from_v32_S (digest[4]) & 7;
    offsetMagicArray += unpack_v8b_from_v32_S (digest[4]) & 7;
    offsetMagicArray += unpack_v8a_from_v32_S (digest[4]) & 7;

    // final

    digest[0] = SHA1M_A;
    digest[1] = SHA1M_B;
    digest[2] = SHA1M_C;
    digest[3] = SHA1M_D;
    digest[4] = SHA1M_E;

    final[ 0] = w0[0];
    final[ 1] = w0[1];
    final[ 2] = w0[2];
    final[ 3] = w0[3];
    final[ 4] = w1[0];
    final[ 5] = w1[1];
    final[ 6] = w1[2];
    final[ 7] = w1[3];
    final[ 8] = w2[0];
    final[ 9] = w2[1];
    final[10] = 0;
    final[11] = 0;
    final[12] = 0;
    final[13] = 0;
    final[14] = 0;
    final[15] = 0;

    u32 final_len = pw_len;

    u32 i;

    // append MagicArray

    for (i = 0; i < lengthMagicArray - 4; i += 4)
    {
      const u32 tmp = GETSHIFTEDINT_CONST (theMagicArray, offsetMagicArray + i);

      SETSHIFTEDINT (final, final_len + i, tmp);
    }

    const u32 mask = 0xffffffff << (((4 - (lengthMagicArray - i)) & 3) * 8);

    const u32 tmp = GETSHIFTEDINT_CONST (theMagicArray, offsetMagicArray + i) & mask;

    SETSHIFTEDINT (final, final_len + i, tmp);

    final_len += lengthMagicArray;

    // append Salt

    for (i = 0; i < salt_len + 1; i += 4) // +1 for the 0x80
    {
      const u32 tmp = salt_buf[i / 4]; // attention, int[] not char[]

      SETSHIFTEDINT (final, final_len + i, tmp);
    }

    final_len += salt_len;

    // calculate

    if (final_len >= 56)
    {
      final[30] = 0;
      final[31] = final_len * 8;

      sha1_transform (final +  0, final +  4, final +  8, final + 12, digest);
      sha1_transform (final + 16, final + 20, final + 24, final + 28, digest);
    }
    else
    {
      final[14] = 0;
      final[15] = final_len * 8;

      sha1_transform (final +  0, final +  4, final +  8, final + 12, digest);
    }

    COMPARE_M_SIMD (0, 0, digest[2] & 0xffff0000, digest[1]);
  }
}

DECLSPEC void m07801s (PRIVATE_AS u32 *w0, PRIVATE_AS u32 *w1, PRIVATE_AS u32 *w2, PRIVATE_AS u32 *w3, const u32 pw_len, KERN_ATTR_FUNC_BASIC ())
{
  /**
   * modifiers are taken from args
   */

  /**
   * salt
   */

  u32 salt_buf[4];

  salt_buf[0] = hc_swap32_S (salt_bufs[SALT_POS_HOST].salt_buf[0]);
  salt_buf[1] = hc_swap32_S (salt_bufs[SALT_POS_HOST].salt_buf[1]);
  salt_buf[2] = hc_swap32_S (salt_bufs[SALT_POS_HOST].salt_buf[2]);
  salt_buf[3] = hc_swap32_S (salt_bufs[SALT_POS_HOST].salt_buf[3]);

  const u32 salt_len = salt_bufs[SALT_POS_HOST].salt_len;

  u32 s0[4];
  u32 s1[4];
  u32 s2[4];
  u32 s3[4];

  s0[0] = salt_buf[0];
  s0[1] = salt_buf[1];
  s0[2] = salt_buf[2];
  s0[3] = salt_buf[3];
  s1[0] = 0;
  s1[1] = 0;
  s1[2] = 0;
  s1[3] = 0;
  s2[0] = 0;
  s2[1] = 0;
  s2[2] = 0;
  s2[3] = 0;
  s3[0] = 0;
  s3[1] = 0;
  s3[2] = 0;
  s3[3] = 0;

  switch_buffer_by_offset_be_S (s0, s1, s2, s3, pw_len);

  const u32x pw_salt_len = pw_len + salt_len;

  /**
   * digest
   */

  const u32 search[4] =
  {
    digests_buf[DIGESTS_OFFSET_HOST].digest_buf[DGST_R0],
    digests_buf[DIGESTS_OFFSET_HOST].digest_buf[DGST_R1],
    digests_buf[DIGESTS_OFFSET_HOST].digest_buf[DGST_R2],
    digests_buf[DIGESTS_OFFSET_HOST].digest_buf[DGST_R3]
  };

  /**
   * loop
   */

  u32 w0l = w0[0];

  for (u32 il_pos = 0; il_pos < IL_CNT; il_pos += VECT_SIZE)
  {
    const u32x w0r = ix_create_bft (bfs_buf, il_pos);

    const u32x w0lr = w0l | w0r;

    w0[0] = w0lr;

    /**
     * SAP
     */

    u32 final[32];

    final[ 0] = w0[0] | s0[0];
    final[ 1] = w0[1] | s0[1];
    final[ 2] = w0[2] | s0[2];
    final[ 3] = w0[3] | s0[3];
    final[ 4] = w1[0] | s1[0];
    final[ 5] = w1[1] | s1[1];
    final[ 6] = w1[2] | s1[2];
    final[ 7] = w1[3] | s1[3];
    final[ 8] = w2[0] | s2[0];
    final[ 9] = w2[1] | s2[1];
    final[10] = w2[2] | s2[2];
    final[11] = w2[3] | s2[3];
    final[12] = w3[0] | s3[0];
    final[13] = w3[1] | s3[1];
    final[14] = 0;
    final[15] = pw_salt_len * 8;
    final[16] = 0;
    final[17] = 0;
    final[18] = 0;
    final[19] = 0;
    final[20] = 0;
    final[21] = 0;
    final[22] = 0;
    final[23] = 0;
    final[24] = 0;
    final[25] = 0;
    final[26] = 0;
    final[27] = 0;
    final[28] = 0;
    final[29] = 0;
    final[30] = 0;
    final[31] = 0;

    u32 digest[5];

    digest[0] = SHA1M_A;
    digest[1] = SHA1M_B;
    digest[2] = SHA1M_C;
    digest[3] = SHA1M_D;
    digest[4] = SHA1M_E;

    sha1_transform (final +  0, final +  4, final +  8, final + 12, digest);

    // prepare magic array range

    u32 lengthMagicArray = 0x20;
    u32 offsetMagicArray = 0;

    lengthMagicArray += unpack_v8d_from_v32_S (digest[0]) % 6;
    lengthMagicArray += unpack_v8c_from_v32_S (digest[0]) % 6;
    lengthMagicArray += unpack_v8b_from_v32_S (digest[0]) % 6;
    lengthMagicArray += unpack_v8a_from_v32_S (digest[0]) % 6;
    lengthMagicArray += unpack_v8d_from_v32_S (digest[1]) % 6;
    lengthMagicArray += unpack_v8c_from_v32_S (digest[1]) % 6;
    lengthMagicArray += unpack_v8b_from_v32_S (digest[1]) % 6;
    lengthMagicArray += unpack_v8a_from_v32_S (digest[1]) % 6;
    lengthMagicArray += unpack_v8d_from_v32_S (digest[2]) % 6;
    lengthMagicArray += unpack_v8c_from_v32_S (digest[2]) % 6;
    offsetMagicArray += unpack_v8b_from_v32_S (digest[2]) & 7;
    offsetMagicArray += unpack_v8a_from_v32_S (digest[2]) & 7;
    offsetMagicArray += unpack_v8d_from_v32_S (digest[3]) & 7;
    offsetMagicArray += unpack_v8c_from_v32_S (digest[3]) & 7;
    offsetMagicArray += unpack_v8b_from_v32_S (digest[3]) & 7;
    offsetMagicArray += unpack_v8a_from_v32_S (digest[3]) & 7;
    offsetMagicArray += unpack_v8d_from_v32_S (digest[4]) & 7;
    offsetMagicArray += unpack_v8c_from_v32_S (digest[4]) & 7;
    offsetMagicArray += unpack_v8b_from_v32_S (digest[4]) & 7;
    offsetMagicArray += unpack_v8a_from_v32_S (digest[4]) & 7;

    // final

    digest[0] = SHA1M_A;
    digest[1] = SHA1M_B;
    digest[2] = SHA1M_C;
    digest[3] = SHA1M_D;
    digest[4] = SHA1M_E;

    final[ 0] = w0[0];
    final[ 1] = w0[1];
    final[ 2] = w0[2];
    final[ 3] = w0[3];
    final[ 4] = w1[0];
    final[ 5] = w1[1];
    final[ 6] = w1[2];
    final[ 7] = w1[3];
    final[ 8] = w2[0];
    final[ 9] = w2[1];
    final[10] = 0;
    final[11] = 0;
    final[12] = 0;
    final[13] = 0;
    final[14] = 0;
    final[15] = 0;

    u32 final_len = pw_len;

    u32 i;

    // append MagicArray

    for (i = 0; i < lengthMagicArray - 4; i += 4)
    {
      const u32 tmp = GETSHIFTEDINT_CONST (theMagicArray, offsetMagicArray + i);

      SETSHIFTEDINT (final, final_len + i, tmp);
    }

    const u32 mask = 0xffffffff << (((4 - (lengthMagicArray - i)) & 3) * 8);

    const u32 tmp = GETSHIFTEDINT_CONST (theMagicArray, offsetMagicArray + i) & mask;

    SETSHIFTEDINT (final, final_len + i, tmp);

    final_len += lengthMagicArray;

    // append Salt

    for (i = 0; i < salt_len + 1; i += 4) // +1 for the 0x80
    {
      const u32 tmp = salt_buf[i / 4]; // attention, int[] not char[]

      SETSHIFTEDINT (final, final_len + i, tmp);
    }

    final_len += salt_len;

    // calculate

    if (final_len >= 56)
    {
      final[30] = 0;
      final[31] = final_len * 8;

      sha1_transform (final +  0, final +  4, final +  8, final + 12, digest);
      sha1_transform (final + 16, final + 20, final + 24, final + 28, digest);
    }
    else
    {
      final[14] = 0;
      final[15] = final_len * 8;

      sha1_transform (final +  0, final +  4, final +  8, final + 12, digest);
    }

    COMPARE_S_SIMD (0, 0, digest[2] & 0xffff0000, digest[1]);
  }
}

KERNEL_FQ KERNEL_FA void m07801_m04 (KERN_ATTR_BASIC ())
{
  /**
   * base
   */

  const u64 lid = get_local_id (0);
  const u64 gid = get_global_id (0);
  const u64 lsz = get_local_size (0);

  if (gid >= GID_CNT) return;

  /**
   * modifier
   */

  u32 w0[4];

  w0[0] = pws[gid].i[ 0];
  w0[1] = pws[gid].i[ 1];
  w0[2] = pws[gid].i[ 2];
  w0[3] = pws[gid].i[ 3];

  u32 w1[4];

  w1[0] = 0;
  w1[1] = 0;
  w1[2] = 0;
  w1[3] = 0;

  u32 w2[4];

  w2[0] = 0;
  w2[1] = 0;
  w2[2] = 0;
  w2[3] = 0;

  u32 w3[4];

  w3[0] = 0;
  w3[1] = 0;
  w3[2] = 0;
  w3[3] = 0;

  const u32 pw_len = pws[gid].pw_len & 63;

  /**
   * main
   */

  m07801m (w0, w1, w2, w3, pw_len, pws, rules_buf, combs_buf, bfs_buf, tmps, hooks, bitmaps_buf_s1_a, bitmaps_buf_s1_b, bitmaps_buf_s1_c, bitmaps_buf_s1_d, bitmaps_buf_s2_a, bitmaps_buf_s2_b, bitmaps_buf_s2_c, bitmaps_buf_s2_d, plains_buf, digests_buf, hashes_shown, salt_bufs, esalt_bufs, d_return_buf, d_extra0_buf, d_extra1_buf, d_extra2_buf, d_extra3_buf, kernel_param, gid, lid, lsz);
}

KERNEL_FQ KERNEL_FA void m07801_m08 (KERN_ATTR_BASIC ())
{
  /**
   * base
   */

  const u64 lid = get_local_id (0);
  const u64 gid = get_global_id (0);
  const u64 lsz = get_local_size (0);

  if (gid >= GID_CNT) return;

  /**
   * modifier
   */

  u32 w0[4];

  w0[0] = pws[gid].i[ 0];
  w0[1] = pws[gid].i[ 1];
  w0[2] = pws[gid].i[ 2];
  w0[3] = pws[gid].i[ 3];

  u32 w1[4];

  w1[0] = pws[gid].i[ 4];
  w1[1] = pws[gid].i[ 5];
  w1[2] = pws[gid].i[ 6];
  w1[3] = pws[gid].i[ 7];

  u32 w2[4];

  w2[0] = 0;
  w2[1] = 0;
  w2[2] = 0;
  w2[3] = 0;

  u32 w3[4];

  w3[0] = 0;
  w3[1] = 0;
  w3[2] = 0;
  w3[3] = 0;

  const u32 pw_len = pws[gid].pw_len & 63;

  /**
   * main
   */

  m07801m (w0, w1, w2, w3, pw_len, pws, rules_buf, combs_buf, bfs_buf, tmps, hooks, bitmaps_buf_s1_a, bitmaps_buf_s1_b, bitmaps_buf_s1_c, bitmaps_buf_s1_d, bitmaps_buf_s2_a, bitmaps_buf_s2_b, bitmaps_buf_s2_c, bitmaps_buf_s2_d, plains_buf, digests_buf, hashes_shown, salt_bufs, esalt_bufs, d_return_buf, d_extra0_buf, d_extra1_buf, d_extra2_buf, d_extra3_buf, kernel_param, gid, lid, lsz);
}

KERNEL_FQ KERNEL_FA void m07801_m16 (KERN_ATTR_BASIC ())
{
  /**
   * base
   */

  const u64 lid = get_local_id (0);
  const u64 gid = get_global_id (0);
  const u64 lsz = get_local_size (0);

  if (gid >= GID_CNT) return;

  /**
   * modifier
   */

  u32 w0[4];

  w0[0] = pws[gid].i[ 0];
  w0[1] = pws[gid].i[ 1];
  w0[2] = pws[gid].i[ 2];
  w0[3] = pws[gid].i[ 3];

  u32 w1[4];

  w1[0] = pws[gid].i[ 4];
  w1[1] = pws[gid].i[ 5];
  w1[2] = pws[gid].i[ 6];
  w1[3] = pws[gid].i[ 7];

  u32 w2[4];

  w2[0] = pws[gid].i[ 8];
  w2[1] = pws[gid].i[ 9];
  w2[2] = pws[gid].i[10];
  w2[3] = pws[gid].i[11];

  u32 w3[4];

  w3[0] = pws[gid].i[12];
  w3[1] = pws[gid].i[13];
  w3[2] = 0;
  w3[3] = 0;

  const u32 pw_len = pws[gid].pw_len & 63;

  /**
   * main
   */

  m07801m (w0, w1, w2, w3, pw_len, pws, rules_buf, combs_buf, bfs_buf, tmps, hooks, bitmaps_buf_s1_a, bitmaps_buf_s1_b, bitmaps_buf_s1_c, bitmaps_buf_s1_d, bitmaps_buf_s2_a, bitmaps_buf_s2_b, bitmaps_buf_s2_c, bitmaps_buf_s2_d, plains_buf, digests_buf, hashes_shown, salt_bufs, esalt_bufs, d_return_buf, d_extra0_buf, d_extra1_buf, d_extra2_buf, d_extra3_buf, kernel_param, gid, lid, lsz);
}

KERNEL_FQ KERNEL_FA void m07801_s04 (KERN_ATTR_BASIC ())
{
  /**
   * base
   */

  const u64 lid = get_local_id (0);
  const u64 gid = get_global_id (0);
  const u64 lsz = get_local_size (0);

  if (gid >= GID_CNT) return;

  /**
   * modifier
   */

  u32 w0[4];

  w0[0] = pws[gid].i[ 0];
  w0[1] = pws[gid].i[ 1];
  w0[2] = pws[gid].i[ 2];
  w0[3] = pws[gid].i[ 3];

  u32 w1[4];

  w1[0] = 0;
  w1[1] = 0;
  w1[2] = 0;
  w1[3] = 0;

  u32 w2[4];

  w2[0] = 0;
  w2[1] = 0;
  w2[2] = 0;
  w2[3] = 0;

  u32 w3[4];

  w3[0] = 0;
  w3[1] = 0;
  w3[2] = 0;
  w3[3] = 0;

  const u32 pw_len = pws[gid].pw_len & 63;

  /**
   * main
   */

  m07801s (w0, w1, w2, w3, pw_len, pws, rules_buf, combs_buf, bfs_buf, tmps, hooks, bitmaps_buf_s1_a, bitmaps_buf_s1_b, bitmaps_buf_s1_c, bitmaps_buf_s1_d, bitmaps_buf_s2_a, bitmaps_buf_s2_b, bitmaps_buf_s2_c, bitmaps_buf_s2_d, plains_buf, digests_buf, hashes_shown, salt_bufs, esalt_bufs, d_return_buf, d_extra0_buf, d_extra1_buf, d_extra2_buf, d_extra3_buf, kernel_param, gid, lid, lsz);
}

KERNEL_FQ KERNEL_FA void m07801_s08 (KERN_ATTR_BASIC ())
{
  /**
   * base
   */

  const u64 lid = get_local_id (0);
  const u64 gid = get_global_id (0);
  const u64 lsz = get_local_size (0);

  if (gid >= GID_CNT) return;

  /**
   * modifier
   */

  u32 w0[4];

  w0[0] = pws[gid].i[ 0];
  w0[1] = pws[gid].i[ 1];
  w0[2] = pws[gid].i[ 2];
  w0[3] = pws[gid].i[ 3];

  u32 w1[4];

  w1[0] = pws[gid].i[ 4];
  w1[1] = pws[gid].i[ 5];
  w1[2] = pws[gid].i[ 6];
  w1[3] = pws[gid].i[ 7];

  u32 w2[4];

  w2[0] = 0;
  w2[1] = 0;
  w2[2] = 0;
  w2[3] = 0;

  u32 w3[4];

  w3[0] = 0;
  w3[1] = 0;
  w3[2] = 0;
  w3[3] = 0;

  const u32 pw_len = pws[gid].pw_len & 63;

  /**
   * main
   */

  m07801s (w0, w1, w2, w3, pw_len, pws, rules_buf, combs_buf, bfs_buf, tmps, hooks, bitmaps_buf_s1_a, bitmaps_buf_s1_b, bitmaps_buf_s1_c, bitmaps_buf_s1_d, bitmaps_buf_s2_a, bitmaps_buf_s2_b, bitmaps_buf_s2_c, bitmaps_buf_s2_d, plains_buf, digests_buf, hashes_shown, salt_bufs, esalt_bufs, d_return_buf, d_extra0_buf, d_extra1_buf, d_extra2_buf, d_extra3_buf, kernel_param, gid, lid, lsz);
}

KERNEL_FQ KERNEL_FA void m07801_s16 (KERN_ATTR_BASIC ())
{
  /**
   * base
   */

  const u64 lid = get_local_id (0);
  const u64 gid = get_global_id (0);
  const u64 lsz = get_local_size (0);

  if (gid >= GID_CNT) return;

  /**
   * modifier
   */

  u32 w0[4];

  w0[0] = pws[gid].i[ 0];
  w0[1] = pws[gid].i[ 1];
  w0[2] = pws[gid].i[ 2];
  w0[3] = pws[gid].i[ 3];

  u32 w1[4];

  w1[0] = pws[gid].i[ 4];
  w1[1] = pws[gid].i[ 5];
  w1[2] = pws[gid].i[ 6];
  w1[3] = pws[gid].i[ 7];

  u32 w2[4];

  w2[0] = pws[gid].i[ 8];
  w2[1] = pws[gid].i[ 9];
  w2[2] = pws[gid].i[10];
  w2[3] = pws[gid].i[11];

  u32 w3[4];

  w3[0] = pws[gid].i[12];
  w3[1] = pws[gid].i[13];
  w3[2] = 0;
  w3[3] = 0;

  const u32 pw_len = pws[gid].pw_len & 63;

  /**
   * main
   */

  m07801s (w0, w1, w2, w3, pw_len, pws, rules_buf, combs_buf, bfs_buf, tmps, hooks, bitmaps_buf_s1_a, bitmaps_buf_s1_b, bitmaps_buf_s1_c, bitmaps_buf_s1_d, bitmaps_buf_s2_a, bitmaps_buf_s2_b, bitmaps_buf_s2_c, bitmaps_buf_s2_d, plains_buf, digests_buf, hashes_shown, salt_bufs, esalt_bufs, d_return_buf, d_extra0_buf, d_extra1_buf, d_extra2_buf, d_extra3_buf, kernel_param, gid, lid, lsz);
}
