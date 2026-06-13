#!/bin/sh

echo "=========================================="
echo "软件源更新脚本"
echo "=========================================="

# 删除旧文件
echo ""
echo "1、删除旧版文件"
 rm -f Packages Packages.bz2 Packages.gz Packages.xz Release
echo "  已删除旧文件"

# 生成 Packages
echo ""
echo "2、生成 Packages"

# 清空并重新写入
> Packages

echo ""
echo "开始处理插件..."

# ============================================================
# 插件1: dev.sys.dipp (roothide)
# ============================================================
pkgname="dev.sys.dipp"
version="1.0"
architecture="all"
maintainer="DPP"
depends="firmware (>= 14.0), mobilesubstrate"
description="roothide安装此版本"
filename="roothide/dpp-roothide.deb"
name="DPP(roothide)"
section="Tweaks"
priority="optional"
author="Apple"

if [ -f "$filename" ]; then
    size=$(stat -c%s "$filename" 2>/dev/null || stat -f%z "$filename" 2>/dev/null)
    md5=$(md5sum "$filename" 2>/dev/null | cut -d' ' -f1)
    sha1=$(sha1sum "$filename" 2>/dev/null | cut -d' ' -f1)
    sha256=$(sha256sum "$filename" 2>/dev/null | cut -d' ' -f1)
    
    cat >> Packages << EOF
Package: $pkgname
Version: $version
Architecture: $architecture
Maintainer: $maintainer
Depends: $depends
Filename: $filename
Size: $size
MD5sum: $md5
SHA1: $sha1
SHA256: $sha256
Section: $section
Priority: $priority
Description: $description
Author: $author
Name: $name

EOF
    echo "  ✅ 已添加: $pkgname"
else
    echo "  ❌ 警告: 文件不存在 - $filename"
fi

# ============================================================
# 插件2: com.dao.afc2 (rootless)
# ============================================================
pkgname="com.dao.afc2"
version="1.1.7-1"
architecture="iphoneos-arm64"
maintainer="Cannathea <csupport@cannathea.com>"
depends="cy+cpu.arm64, mobilesubstrate, firmware (>= 11.0), ldid | firmware (>= 15.0)"
pre_depends="dpkg (>= 1.14.25-8)"
conflicts="com.saurik.afc2d, net.angelxwind.afc2d-arm64, com.mrmadtw.afc2forios11, repo.feng.afc2add11, us.scw.afctwoadd, net.angelxwind.afc2ios70, afc2.25pp, afc2.25pp7, afc2.91, app.taig.afc2, com.cannathea.afc2d-arm64, com.82skao.afc2d-arm64"
replaces="com.saurik.afc2d, net.angelxwind.afc2d-arm64, com.mrmadtw.afc2forios11, repo.feng.afc2add11, us.scw.afctwoadd, net.angelxwind.afc2ios70, afc2.25pp, afc2.25pp7, afc2.91, app.taig.afc2"
provides="com.saurik.afc2d, net.angelxwind.afc2d-arm64, com.mrmadtw.afc2forios11, repo.feng.afc2add11, us.scw.afctwoadd, net.angelxwind.afc2ios70, afc2.25pp, afc2.25pp7, afc2.91, app.taig.afc2"
description="允许设备通过USB访问完整的文件系统，对iOS 11及更高版本的设备特别有用"
filename="rootless/AFC2(rootless).deb"
name="AFC2(rootless)"
section="Tweaks"

if ls rootless/AFC2*.deb >/dev/null 2>&1; then
    actual_file=$(ls rootless/AFC2*.deb 2>/dev/null | head -1)
    filename="$actual_file"
    
    size=$(stat -c%s "$actual_file" 2>/dev/null || stat -f%z "$actual_file" 2>/dev/null)
    md5=$(md5sum "$actual_file" 2>/dev/null | cut -d' ' -f1)
    sha1=$(sha1sum "$actual_file" 2>/dev/null | cut -d' ' -f1)
    sha256=$(sha256sum "$actual_file" 2>/dev/null | cut -d' ' -f1)
    
    filename_clean=$(echo "$filename" | sed 's|^\./||')
    
    cat >> Packages << EOF
Package: $pkgname
Version: $version
Architecture: $architecture
Maintainer: $maintainer
Pre-Depends: $pre_depends
Depends: $depends
Conflicts: $conflicts
Replaces: $replaces
Provides: $provides
Filename: $filename_clean
Size: $size
MD5sum: $md5
SHA1: $sha1
SHA256: $sha256
Section: $section
Description: $description
Author: saurik, Cannathea <csupport@cannathea.com>
Name: $name

EOF
    echo "  ✅ 已添加: $pkgname (文件: $(basename "$actual_file"))"
else
    echo "  ❌ 警告: 文件不存在 - rootless/AFC2*.deb"
fi

# ============================================================
# 插件3: dev.sys.dpprootless (rootless)
# ============================================================
pkgname="dev.sys.dpprootless"
version="1.0"
architecture="all"
maintainer="DPP"
depends="firmware (>= 14.0), mobilesubstrate"
description="rootless安装此版本"
filename="rootless/dpp.deb"
name="DPP"
section="Tweaks"
priority="optional"
author="Apple"

if [ -f "$filename" ]; then
    size=$(stat -c%s "$filename" 2>/dev/null || stat -f%z "$filename" 2>/dev/null)
    md5=$(md5sum "$filename" 2>/dev/null | cut -d' ' -f1)
    sha1=$(sha1sum "$filename" 2>/dev/null | cut -d' ' -f1)
    sha256=$(sha256sum "$filename" 2>/dev/null | cut -d' ' -f1)
    
    cat >> Packages << EOF
Package: $pkgname
Version: $version
Architecture: $architecture
Maintainer: $maintainer
Depends: $depends
Filename: $filename
Size: $size
MD5sum: $md5
SHA1: $sha1
SHA256: $sha256
Section: $section
Priority: $priority
Description: $description
Author: $author
Name: $name

EOF
    echo "  ✅ 已添加: $pkgname"
else
    echo "  ❌ 警告: 文件不存在 - $filename"
fi

echo ""
echo "生成的包数量: $(grep -c '^Package:' Packages)"

# ============================================================
# 压缩
# ============================================================
echo ""
echo "3、压缩文件"

# bzip2
cat Packages | bzip2 > Packages.bz2
echo "  生成: Packages.bz2"

# gzip
cat Packages | gzip > Packages.gz
echo "  生成: Packages.gz"

# xz（可选）
if command -v xz >/dev/null 2>&1; then
    cat Packages | xz > Packages.xz
    echo "  生成: Packages.xz"
else
    echo "  ⚠️ 跳过: xz 命令不存在"
fi

# ============================================================
# 生成 Release
# ============================================================
echo ""
echo "4、生成 Release 文件"

# 生成 Release 文件（直接写入，格式正确）
cat > Release << EOF
Origin: dpp软改工具
Label: dpp软改工具
Suite: stable
Version: 1.0
Codename: ios
Architectures: iphoneos-arm iphoneos-arm64 iphoneos-arm64e
Components: main
Description: 仅用于学习交流
Date: $(date -u +"%a, %d %b %Y %H:%M:%S UTC")

MD5Sum:
 $(md5sum Packages 2>/dev/null | awk '{print $1" "$2" Packages"}')
 $(md5sum Packages.bz2 2>/dev/null | awk '{print $1" "$2" Packages.bz2"}')
 $(md5sum Packages.gz 2>/dev/null | awk '{print $1" "$2" Packages.gz"}')
EOF

# 如果 xz 存在，添加
if [ -f Packages.xz ]; then
    cat >> Release << EOF
 $(md5sum Packages.xz 2>/dev/null | awk '{print $1" "$2" Packages.xz"}')
EOF
fi

# SHA1
cat >> Release << EOF

SHA1:
 $(sha1sum Packages 2>/dev/null | awk '{print $1" "$2" Packages"}')
 $(sha1sum Packages.bz2 2>/dev/null | awk '{print $1" "$2" Packages.bz2"}')
 $(sha1sum Packages.gz 2>/dev/null | awk '{print $1" "$2" Packages.gz"}')
EOF

if [ -f Packages.xz ]; then
    cat >> Release << EOF
 $(sha1sum Packages.xz 2>/dev/null | awk '{print $1" "$2" Packages.xz"}')
EOF
fi

# SHA256
cat >> Release << EOF

SHA256:
 $(sha256sum Packages 2>/dev/null | awk '{print $1" "$2" Packages"}')
 $(sha256sum Packages.bz2 2>/dev/null | awk '{print $1" "$2" Packages.bz2"}')
 $(sha256sum Packages.gz 2>/dev/null | awk '{print $1" "$2" Packages.gz"}')
EOF

if [ -f Packages.xz ]; then
    cat >> Release << EOF
 $(sha256sum Packages.xz 2>/dev/null | awk '{print $1" "$2" Packages.xz"}')
EOF
fi

echo "  生成: Release"

# 验证
echo ""
echo "=========================================="
echo "验证哈希一致性"
if [ -f Packages.bz2 ]; then
    echo "Packages.bz2 MD5: $(md5sum Packages.bz2 2>/dev/null | cut -d' ' -f1)"
    echo "Release MD5: $(grep Packages.bz2 Release | head -1 | awk '{print $1}')"
fi

echo ""
echo "生成完成！文件列表："
ls -la Packages* Release
echo "=========================================="

# ============================================================
# 推送
# ============================================================
echo ""
echo "5、推送到 GitHub"

git add Packages Packages.bz2 Packages.gz Release
if [ -f Packages.xz ]; then
    git add Packages.xz
fi
git commit -m "update repo"

if git push; then
    echo "✅ 推送成功！"
else
    echo "❌ 推送失败，请手动上传文件"
fi

echo ""
echo "完成！"