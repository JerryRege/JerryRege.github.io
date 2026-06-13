#!/usr/bin/env python
# -*- coding: utf-8 -*-
import os
import sys
import hashlib
import bz2
import gzip
import tarfile
import tempfile
import subprocess
from datetime import datetime

# ========== 配置（修改成你的信息）==========
ORIGIN = "Lanbao Repo"
LABEL = "Lanbao Source"
SUITE = "stable"
VERSION = "1.0"
CODENAME = "ios"
ARCHITECTURES = "iphoneos-arm iphoneos-arm64 iphoneos-arm64e"
COMPONENTS = "main"
DESCRIPTION = "仅用于学习交流"
# ========================================

# 要扫描的架构目录
ARCH_DIRS = ["roothide", "rootless", "rootful"]


def extract_control(deb_path):
    """从 deb 包中提取 control 文件内容"""
    try:
        with tempfile.TemporaryDirectory() as tmpdir:
            # 用 7z 解压
            result = subprocess.run(
                [r"C:\Program Files\7-Zip\7z.exe", "x", deb_path, f"-o{tmpdir}"],
                capture_output=True,
                text=True
            )
            
            if result.returncode == 0:
                # 直接 control 文件
                control_path = os.path.join(tmpdir, "control")
                if os.path.exists(control_path):
                    with open(control_path, "r", encoding="utf-8", errors="ignore") as f:
                        return f.read()
                
                # control.tar.gz
                tar_gz = os.path.join(tmpdir, "control.tar.gz")
                if os.path.exists(tar_gz):
                    with tarfile.open(tar_gz, "r:gz") as tar:
                        if "control" in tar.getnames():
                            return tar.extractfile("control").read().decode("utf-8", errors="ignore")
                
                # control.tar.xz
                tar_xz = os.path.join(tmpdir, "control.tar.xz")
                if os.path.exists(tar_xz):
                    with tarfile.open(tar_xz, "r:xz") as tar:
                        if "control" in tar.getnames():
                            return tar.extractfile("control").read().decode("utf-8", errors="ignore")
    except Exception as e:
        print(f"  解压失败: {e}")
    return None


def main():
    print("正在扫描 deb 文件...")
    
    packages_list = []
    
    for arch_dir in ARCH_DIRS:
        if not os.path.isdir(arch_dir):
            continue
        
        print(f"扫描: {arch_dir}/")
        
        for root, dirs, files in os.walk(arch_dir):
            for file in files:
                if not file.endswith(".deb"):
                    continue
                
                deb_path = os.path.join(root, file)
                print(f"  处理: {file}")
                
                control = extract_control(deb_path)
                if not control:
                    print(f"    警告: 无法提取 control，跳过")
                    continue
                
                # 计算哈希
                with open(deb_path, "rb") as f:
                    data = f.read()
                    md5 = hashlib.md5(data).hexdigest()
                    sha1 = hashlib.sha1(data).hexdigest()
                    sha256 = hashlib.sha256(data).hexdigest()
                    size = len(data)
                
                # 相对路径（用于 Filename）
                rel_path = os.path.relpath(deb_path).replace("\\", "/")
                
                pkg = control.strip()
                pkg += f"\nMD5sum: {md5}"
                pkg += f"\nSHA1: {sha1}"
                pkg += f"\nSHA256: {sha256}"
                pkg += f"\nFilename: {rel_path}"
                pkg += f"\nSize: {size}\n"
                packages_list.append(pkg)
    
    if not packages_list:
        print("错误: 没有找到任何 deb 文件")
        print("请确保 roothide/rootless/rootful 文件夹里有 .deb 文件")
        sys.exit(1)
    
    print(f"\n共找到 {len(packages_list)} 个 deb 包")
    
    # 写入 Packages
    with open("Packages", "w", encoding="utf-8") as f:
        f.write("\n\n".join(packages_list))
    print("生成: Packages")
    
    # 压缩
    with open("Packages", "rb") as f_in:
        data = f_in.read()
        with bz2.open("Packages.bz2", "wb") as f_out:
            f_out.write(data)
        with gzip.open("Packages.gz", "wb") as f_out:
            f_out.write(data)
    print("生成: Packages.bz2, Packages.gz")
    
    # 生成 Release（包含校验和）
    release_lines = [
        f"Origin: {ORIGIN}",
        f"Label: {LABEL}",
        f"Suite: {SUITE}",
        f"Version: {VERSION}",
        f"Codename: {CODENAME}",
        f"Architectures: {ARCHITECTURES}",
        f"Components: {COMPONENTS}",
        f"Description: {DESCRIPTION}",
        f"Date: {datetime.utcnow().strftime('%a, %d %b %Y %H:%M:%S UTC')}",
        ""
    ]
    
    index_files = ["Packages", "Packages.bz2", "Packages.gz"]
    
    for hash_name in ["MD5Sum", "SHA1", "SHA256"]:
        release_lines.append(f"{hash_name}:")
        for fname in index_files:
            if os.path.exists(fname):
                with open(fname, "rb") as f:
                    h = hashlib.new(hash_name.lower(), f.read()).hexdigest()
                    size = os.path.getsize(fname)
                    release_lines.append(f" {h} {size:10} {fname}")
        release_lines.append("")
    
    with open("Release", "w", encoding="utf-8") as f:
        f.write("\n".join(release_lines))
    print("生成: Release")
    
    print("\n✅ 打包完成！")


if __name__ == "__main__":
    main()