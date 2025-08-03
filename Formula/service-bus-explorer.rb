class ServiceBusExplorer < Formula
  desc "Cross-platform Azure Service Bus management tool"
  homepage "https://github.com/haga0531/service-bus-explorer"
  version "1.0.0"
  
  if OS.mac? && Hardware::CPU.arm?
    url "https://github.com/haga0531/service-bus-explorer/releases/download/v#{version}/ServiceBusExplorer-osx-arm64.tar.gz"
    sha256 "0019dfc4b32d63c1392aa264aed2253c1e0c2fb09216f8e2cc269bbfb8bb49b5"
  elsif OS.mac?
    url "https://github.com/haga0531/service-bus-explorer/releases/download/v#{version}/ServiceBusExplorer-osx-x64.tar.gz"
    sha256 "0019dfc4b32d63c1392aa264aed2253c1e0c2fb09216f8e2cc269bbfb8bb49b5"
  elsif OS.linux?
    url "https://github.com/haga0531/service-bus-explorer/releases/download/v#{version}/ServiceBusExplorer-linux-x64.tar.gz"
    sha256 "0019dfc4b32d63c1392aa264aed2253c1e0c2fb09216f8e2cc269bbfb8bb49b5"
  end

  def install
    if OS.mac?
      # v1.0.0の実際の構造に合わせて修正
      # "Service Bus Explorer.app" が含まれているか確認
      app_bundle = "Service Bus Explorer.app"
      
      if File.directory?(app_bundle)
        # .app バンドルがある場合（期待される構造）
        prefix.install app_bundle
        
        # 実行ファイルへのシンボリックリンクを作成
        bin.install_symlink prefix/"#{app_bundle}/Contents/MacOS/ServiceBusExplorer.UI" => "service-bus-explorer"
      elsif File.directory?("Contents")
        # Contentsディレクトリだけがある場合（現在の問題）
        # 手動で.appバンドル構造を作成
        app_dir = prefix/"Service Bus Explorer.app"
        app_dir.mkpath
        cp_r "Contents", app_dir/"Contents"
        
        # 実行ファイルへのシンボリックリンクを作成
        bin.install_symlink app_dir/"Contents/MacOS/ServiceBusExplorer.UI" => "service-bus-explorer"
      else
        # フォールバック：すべてをインストール
        prefix.install Dir["*"]
        
        # ServiceBusExplorer.UIを探して、見つかったらシンボリックリンクを作成
        Find.find(prefix) do |path|
          if File.basename(path) == "ServiceBusExplorer.UI" && File.executable?(path)
            bin.install_symlink path => "service-bus-explorer"
            break
          end
        end
      end
    else
      # Linux
      libexec.install Dir["*"]
      chmod 0755, libexec/"ServiceBusExplorer.UI"
      
      (bin/"service-bus-explorer").write <<~EOS
        #!/bin/bash
        exec "#{libexec}/ServiceBusExplorer.UI" "$@"
      EOS
    end
  end

  def post_install
    if OS.mac?
      ohai "Removing quarantine attributes..."
      system "xattr", "-cr", prefix.to_s
    end
  end

  test do
    assert_predicate bin/"service-bus-explorer", :exist?
    assert_predicate bin/"service-bus-explorer", :executable?
  end
  
  def caveats
    <<~EOS
      Service Bus Explorer has been installed.
      
      To run the application:
        service-bus-explorer
      
      #{if OS.mac?
        "The macOS app is located at:
        #{prefix}/Service Bus Explorer.app
        
        To add to Applications folder:
        ln -s \"#{prefix}/Service Bus Explorer.app\" /Applications/"
      end}
    EOS
  end
end