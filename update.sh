#!/bin/sh

echo "=========================================="
echo "Cydia/Sileo 软件源更新脚本"
echo "=========================================="

# 配置信息
ORIGIN="JerryRege"
LABEL="Lanbao Source"
SUITE="stable"
VERSION="1.0"
CODENAME="ios"
ARCHITECTURES="iphoneos-arm"
COMPONENTS="main"
DESCRIPTION="Personal repository"

echo ""
echo "1、删除旧版文件"
rm -f Packages Packages.bz2 Packages.gz Release

echo ""
echo "2、扫描并生成 Packages"

# 清空并重新生成 Packages
> Packages

# 扫描多个架构目录
for dir in roothide rootless rootful debs; do
    if [ -d "$dir" ]; then
        echo "  扫描目录: $dir/"
        if command -v dpkg-scanpackages >/dev/null 2>&1; then
            dpkg-scanpackages --multiversion "$dir" >> Packages 2>/dev/null
        else
            # 如果没有 dpkg-scanpackages，用 find 手动处理
            for deb in $(find "$dir" -name "*.deb" 2>/dev/null); do
                echo "    处理: $(basename "$deb")"
                # 提取包名（从文件名）
                pkgname=$(basename "$deb" .deb)
                echo "Package: $pkgname" >> Packages
                echo "Version: 1.0" >> Packages
                echo "Architecture: iphoneos-arm" >> Packages
                echo "Filename: $deb" >> Packages
                echo "" >> Packages
            done
        fi
    fi
done

# 检查是否有内容
if [ ! -s Packages ]; then
    echo "错误: 没有找到任何 deb 文件"
    exit 1
fi

echo ""
echo "3、压缩索引文件"

# 只压缩 bz2 和 gz（Sileo 支持）
bzip2 -c Packages > Packages.bz2
gzip -c Packages > Packages.gz
echo "  生成: Packages.bz2"
echo "  生成: Packages.gz"

# 可选：如果需要 xz（可选）
# xz -c Packages > Packages.xz

echo ""
echo "4、生成 Release 文件"

# 计算文件大小和哈希
SIZE_Pkg=$(stat -c%s Packages 2>/dev/null || stat -f%z Packages 2>/dev/null)
SIZE_Pkg_bz2=$(stat -c%s Packages.bz2 2>/dev/null || stat -f%z Packages.bz2 2>/dev/null)
SIZE_Pkg_gz=$(stat -c%s Packages.gz 2>/dev/null || stat -f%z Packages.gz 2>/dev/null)

MD5_Pkg=$(md5sum Packages 2>/dev/null | cut -d' ' -f1)
MD5_Pkg_bz2=$(md5sum Packages.bz2 2>/dev/null | cut -d' ' -f1)
MD5_Pkg_gz=$(md5sum Packages.gz 2>/dev/null | cut -d' ' -f1)

SHA1_Pkg=$(sha1sum Packages 2>/dev/null | cut -d' ' -f1)
SHA1_Pkg_bz2=$(sha1sum Packages.bz2 2>/dev/null | cut -d' ' -f1)
SHA1_Pkg_gz=$(sha1sum Packages.gz 2>/dev/null | cut -d' ' -f1)

SHA256_Pkg=$(sha256sum Packages 2>/dev/null | cut -d' ' -f1)
SHA256_Pkg_bz2=$(sha256sum Packages.bz2 2>/dev/null | cut -d' ' -f1)
SHA256_Pkg_gz=$(sha256sum Packages.gz 2>/dev/null | cut -d' ' -f1)

# 生成 Release 文件
cat > Release << EOF
Origin: $ORIGIN
Label: $LABEL
Suite: $SUITE
Version: $VERSION
Codename: $CODENAME
Architectures: $ARCHITECTURES
Components: $COMPONENTS
Description: $DESCRIPTION
Date: $(date -u +"%a, %d %b %Y %H:%M:%S UTC")

MD5Sum:
 $MD5_Pkg $SIZE_Pkg Packages
 $MD5_Pkg_bz2 $SIZE_Pkg_bz2 Packages.bz2
 $MD5_Pkg_gz $SIZE_Pkg_gz Packages.gz

SHA1:
 $SHA1_Pkg $SIZE_Pkg Packages
 $SHA1_Pkg_bz2 $SIZE_Pkg_bz2 Packages.bz2
 $SHA1_Pkg_gz $SIZE_Pkg_gz Packages.gz

SHA256:
 $SHA256_Pkg $SIZE_Pkg Packages
 $SHA256_Pkg_bz2 $SIZE_Pkg_bz2 Packages.bz2
 $SHA256_Pkg_gz $SIZE_Pkg_gz Packages.gz
EOF

echo "  生成: Release"

echo ""
echo "5、推送到 GitHub"
git add .
git commit -s -m "sync repo"
git push

echo ""
echo "=========================================="
echo "✅ 完成！"
echo "源地址: https://jerryrege.github.io"
echo "=========================================="