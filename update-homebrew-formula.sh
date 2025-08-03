#!/bin/bash

# Homebrew Formula を更新するスクリプト
# 使用方法: ./scripts/update-homebrew-formula.sh v1.0.0

VERSION=$1
if [ -z "$VERSION" ]; then
    echo "Usage: $0 <version>"
    echo "Example: $0 v1.0.0"
    exit 1
fi

# バージョンタグからvを削除
VERSION_NUM=${VERSION#v}

# GitHubのユーザー名とリポジトリ名
GITHUB_USER="haga0531"
REPO_NAME="service-bus-explorer-crossplat"

echo "Updating Homebrew formula for version $VERSION_NUM..."

# 各プラットフォームのSHA256を計算
echo "Downloading and calculating SHA256..."

# macOS ARM64
ARM64_URL="https://github.com/$GITHUB_USER/$REPO_NAME/releases/download/$VERSION/ServiceBusExplorer-osx-arm64.tar.gz"
ARM64_SHA=$(curl -sL "$ARM64_URL" | shasum -a 256 | awk '{print $1}')
echo "ARM64 SHA256: $ARM64_SHA"

# macOS x64
X64_URL="https://github.com/$GITHUB_USER/$REPO_NAME/releases/download/$VERSION/ServiceBusExplorer-osx-x64.tar.gz"
X64_SHA=$(curl -sL "$X64_URL" | shasum -a 256 | awk '{print $1}')
echo "x64 SHA256: $X64_SHA"

# Linux x64
LINUX_URL="https://github.com/$GITHUB_USER/$REPO_NAME/releases/download/$VERSION/ServiceBusExplorer-linux-x64.tar.gz"
LINUX_SHA=$(curl -sL "$LINUX_URL" | shasum -a 256 | awk '{print $1}')
echo "Linux SHA256: $LINUX_SHA"

# Formula ファイルを更新（Homebrew Tapリポジトリで実行することを想定）
FORMULA_FILE="Formula/service-bus-explorer.rb"

# バージョンを更新
sed -i '' "s/version \".*\"/version \"$VERSION_NUM\"/" "$FORMULA_FILE"

# SHA256を更新
sed -i '' "s/sha256 \"PLACEHOLDER_SHA256_ARM64\"/sha256 \"$ARM64_SHA\"/" "$FORMULA_FILE"
sed -i '' "s/sha256 \"PLACEHOLDER_SHA256_X64\"/sha256 \"$X64_SHA\"/" "$FORMULA_FILE"
sed -i '' "s/sha256 \"PLACEHOLDER_SHA256_LINUX\"/sha256 \"$LINUX_SHA\"/" "$FORMULA_FILE"

# 既存のSHA256も更新（2回目以降の更新用）
sed -i '' "s/sha256 \"[a-f0-9]\{64\}\"/sha256 \"$ARM64_SHA\"/1" "$FORMULA_FILE"
sed -i '' "s/sha256 \"[a-f0-9]\{64\}\"/sha256 \"$X64_SHA\"/2" "$FORMULA_FILE"
sed -i '' "s/sha256 \"[a-f0-9]\{64\}\"/sha256 \"$LINUX_SHA\"/3" "$FORMULA_FILE"

echo "Formula updated successfully!"
echo ""
echo "Next steps:"
echo "1. Review the changes: git diff $FORMULA_FILE"
echo "2. Commit: git add $FORMULA_FILE && git commit -m \"Update formula to $VERSION\""
echo "3. Push to homebrew tap repository"