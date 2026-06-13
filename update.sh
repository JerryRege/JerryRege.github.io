#!/bin/sh
echo "1、删除旧版Packages"
rm Packages Packages.*

echo "2、扫描重新生成、压缩Packages"
dpkg-scanpackages --multiversion roothide >> Packages
dpkg-scanpackages --multiversion rootless >> Packages
dpkg-scanpackages --multiversion rootful >> Packages

cat Packages | xz > Packages.xz
cat Packages | bzip2 > Packages.bz2
cat Packages | gzip > Packages.gz
cat Packages | lzma > Packages.lzma
cat Packages | zstd > Packages.zst

apt-ftparchive\
 -o APT::FTPArchive::Release::Origin="dpp隐私保护"\
 -o APT::FTPArchive::Release::Label="dpp隐私保护"\
 -o APT::FTPArchive::Release::Suite="stable"\
 -o APT::FTPArchive::Release::Version="1.0"\
 -o APT::FTPArchive::Release::Codename="ios"\
 -o APT::FTPArchive::Release::Architectures="iphoneos-arm iphoneos-arm64 iphoneos-arm64e"\
 -o APT::FTPArchive::Release::Components="main"\
 -o APT::FTPArchive::Release::Description="仅用于学习交流"\
 release . > Release

echo "3、推送提交"
git add .
git commit -s -m "sync repo"
git push
