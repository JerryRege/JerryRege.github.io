#!/bin/sh
echo "1、删除旧版Packages"
rm -f Packages Packages.*

echo "2、扫描重新生成、压缩Packages"

# 生成 Packages
> Packages
for dir in roothide rootless rootful; do
    if [ -d "$dir" ]; then
        dpkg-scanpackages --multiversion "$dir" >> Packages 2>/dev/null
    fi
done

# 压缩成各种格式
cat Packages | xz > Packages.xz
cat Packages | bzip2 > Packages.bz2
cat Packages | gzip > Packages.gz
cat Packages | lzma > Packages.lzma
cat Packages | zstd > Packages.zst

echo "3、生成 Release 文件"

# 计算所有索引文件的哈希值
MD5_Packages=$(md5sum Packages | cut -d' ' -f1)
MD5_Packages_bz2=$(md5sum Packages.bz2 | cut -d' ' -f1)
MD5_Packages_gz=$(md5sum Packages.gz | cut -d' ' -f1)
MD5_Packages_xz=$(md5sum Packages.xz | cut -d' ' -f1)
MD5_Packages_lzma=$(md5sum Packages.lzma | cut -d' ' -f1)
MD5_Packages_zst=$(md5sum Packages.zst | cut -d' ' -f1)

SHA1_Packages=$(sha1sum Packages | cut -d' ' -f1)
SHA1_Packages_bz2=$(sha1sum Packages.bz2 | cut -d' ' -f1)
SHA1_Packages_gz=$(sha1sum Packages.gz | cut -d' ' -f1)
SHA1_Packages_xz=$(sha1sum Packages.xz | cut -d' ' -f1)
SHA1_Packages_lzma=$(sha1sum Packages.lzma | cut -d' ' -f1)
SHA1_Packages_zst=$(sha1sum Packages.zst | cut -d' ' -f1)

SHA256_Packages=$(sha256sum Packages | cut -d' ' -f1)
SHA256_Packages_bz2=$(sha256sum Packages.bz2 | cut -d' ' -f1)
SHA256_Packages_gz=$(sha256sum Packages.gz | cut -d' ' -f1)
SHA256_Packages_xz=$(sha256sum Packages.xz | cut -d' ' -f1)
SHA256_Packages_lzma=$(sha256sum Packages.lzma | cut -d' ' -f1)
SHA256_Packages_zst=$(sha256sum Packages.zst | cut -d' ' -f1)

# 获取文件大小
SIZE_Packages=$(stat -c%s Packages 2>/dev/null || stat -f%z Packages 2>/dev/null)
SIZE_Packages_bz2=$(stat -c%s Packages.bz2 2>/dev/null || stat -f%z Packages.bz2 2>/dev/null)
SIZE_Packages_gz=$(stat -c%s Packages.gz 2>/dev/null || stat -f%z Packages.gz 2>/dev/null)
SIZE_Packages_xz=$(stat -c%s Packages.xz 2>/dev/null || stat -f%z Packages.xz 2>/dev/null)
SIZE_Packages_lzma=$(stat -c%s Packages.lzma 2>/dev/null || stat -f%z Packages.lzma 2>/dev/null)
SIZE_Packages_zst=$(stat -c%s Packages.zst 2>/dev/null || stat -f%z Packages.zst 2>/dev/null)

# 生成 Release 文件
cat > Release << EOF
Origin: dpp隐私保护
Label: dpp隐私保护
Suite: stable
Version: 1.0
Codename: ios
Architectures: iphoneos-arm iphoneos-arm64 iphoneos-arm64e
Components: main
Description: 仅用于学习交流
Date: $(date -u +"%a, %d %b %Y %H:%M:%S UTC")

MD5Sum:
 $MD5_Packages $SIZE_Packages Packages
 $MD5_Packages_bz2 $SIZE_Packages_bz2 Packages.bz2
 $MD5_Packages_gz $SIZE_Packages_gz Packages.gz
 $MD5_Packages_xz $SIZE_Packages_xz Packages.xz
 $MD5_Packages_lzma $SIZE_Packages_lzma Packages.lzma
 $MD5_Packages_zst $SIZE_Packages_zst Packages.zst

SHA1:
 $SHA1_Packages $SIZE_Packages Packages
 $SHA1_Packages_bz2 $SIZE_Packages_bz2 Packages.bz2
 $SHA1_Packages_gz $SIZE_Packages_gz Packages.gz
 $SHA1_Packages_xz $SIZE_Packages_xz Packages.xz
 $SHA1_Packages_lzma $SIZE_Packages_lzma Packages.lzma
 $SHA1_Packages_zst $SIZE_Packages_zst Packages.zst

SHA256:
 $SHA256_Packages $SIZE_Packages Packages
 $SHA256_Packages_bz2 $SIZE_Packages_bz2 Packages.bz2
 $SHA256_Packages_gz $SIZE_Packages_gz Packages.gz
 $SHA256_Packages_xz $SIZE_Packages_xz Packages.xz
 $SHA256_Packages_lzma $SIZE_Packages_lzma Packages.lzma
 $SHA256_Packages_zst $SIZE_Packages_zst Packages.zst

EOF

echo "4、推送提交"
git add .
git commit -s -m "sync repo"
git push

echo "完成！"