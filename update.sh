#!/bin/sh
echo "1、删除旧版Packages"
rm -f Packages Packages.*

echo "2、生成 Packages（混合模式：元信息写死，哈希动态读取）"

# 清空 Packages 文件
> Packages

# 定义三个插件的信息（写死的部分）
# 格式: "包名|版本|架构|维护者|依赖|描述|文件名路径"
cat > /tmp/pkg_list.txt << 'LIST'
dev.sys.dipp|1.0|all|DPP|firmware (>= 14.0), mobilesubstrate|roothide安装此版本|roothide/dpp-roothide.deb|DPP(roothide)
com.dao.afc2|1.1.7-1|iphoneos-arm64|Cannathea <csupport@cannathea.com>|cy+cpu.arm64, mobilesubstrate, firmware (>= 11.0), ldid \| firmware (>= 15.0)|允许设备通过USB访问完整的文件系统|rootless/AFC2(rootless).deb|AFC2(rootless)
dev.sys.dpprootless|1.0|all|DPP|firmware (>= 14.0), mobilesubstrate|rootless安装此版本|rootless/dpp.deb|DPP
LIST

# 读取列表并处理每个插件
while IFS='|' read -r pkgname version arch maintainer deps description filename name; do
    echo "  处理: $filename"
    
    # 检查 deb 文件是否存在
    if [ ! -f "$filename" ]; then
        echo "    警告: 文件不存在 - $filename"
        continue
    fi
    
    # 动态计算 Size 和哈希
    size=$(stat -c%s "$filename" 2>/dev/null || stat -f%z "$filename" 2>/dev/null)
    md5=$(md5sum "$filename" 2>/dev/null | cut -d' ' -f1)
    sha1=$(sha1sum "$filename" 2>/dev/null | cut -d' ' -f1)
    sha256=$(sha256sum "$filename" 2>/dev/null | cut -d' ' -f1)
    
    # 写入 Packages
    cat >> Packages << EOF
Package: $pkgname
Version: $version
Architecture: $arch
Maintainer: $maintainer
Depends: $deps
Filename: $filename
Size: $size
MD5sum: $md5
SHA1: $sha1
SHA256: $sha256
Section: Tweaks
Priority: optional
Description: $description
Author: Apple
Name: $name

EOF
    
    echo "    已添加: $pkgname ($size bytes)"
done < /tmp/pkg_list.txt

rm -f /tmp/pkg_list.txt

echo "生成的包数量: $(grep -c '^Package:' Packages)"

echo "3、压缩Packages"
# 压缩成各种格式
if command -v xz >/dev/null 2>&1; then
    cat Packages | xz > Packages.xz
    echo "  生成: Packages.xz"
fi
cat Packages | bzip2 > Packages.bz2
echo "  生成: Packages.bz2"
cat Packages | gzip > Packages.gz
echo "  生成: Packages.gz"
if command -v lzma >/dev/null 2>&1; then
    cat Packages | lzma > Packages.lzma
    echo "  生成: Packages.lzma"
fi
if command -v zstd >/dev/null 2>&1; then
    cat Packages | zstd > Packages.zst
    echo "  生成: Packages.zst"
fi

echo "4、生成 Release 文件"

# 生成 Release
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

# 可选压缩格式的校验和（如果文件存在）
if [ -f Packages.xz ]; then
    cat >> Release << EOF
 $(md5sum Packages.xz 2>/dev/null | awk '{print $1" "$2" Packages.xz"}')
EOF
fi
if [ -f Packages.lzma ]; then
    cat >> Release << EOF
 $(md5sum Packages.lzma 2>/dev/null | awk '{print $1" "$2" Packages.lzma"}')
EOF
fi
if [ -f Packages.zst ]; then
    cat >> Release << EOF
 $(md5sum Packages.zst 2>/dev/null | awk '{print $1" "$2" Packages.zst"}')
EOF
fi

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
if [ -f Packages.lzma ]; then
    cat >> Release << EOF
 $(sha1sum Packages.lzma 2>/dev/null | awk '{print $1" "$2" Packages.lzma"}')
EOF
fi
if [ -f Packages.zst ]; then
    cat >> Release << EOF
 $(sha1sum Packages.zst 2>/dev/null | awk '{print $1" "$2" Packages.zst"}')
EOF
fi

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
if [ -f Packages.lzma ]; then
    cat >> Release << EOF
 $(sha256sum Packages.lzma 2>/dev/null | awk '{print $1" "$2" Packages.lzma"}')
EOF
fi
if [ -f Packages.zst ]; then
    cat >> Release << EOF
 $(sha256sum Packages.zst 2>/dev/null | awk '{print $1" "$2" Packages.zst"}')
EOF
fi

echo "  生成: Release"

echo "5、推送提交"
git add .
git commit -s -m "sync repo"
git push

echo "完成！"