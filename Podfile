platform:ios, '6.0'
pod 'CocoaLumberjack', '~> 1.8.1'
pod 'MBProgressHUD', '~> 0.9'
pod 'SSKeychain', '~> 1.2.2'
pod 'JSBadgeView', '~> 1.3.2'
pod 'Base64nl', '~> 1.2'
pod 'KSReachability', '~> 1.4'
pod 'CHTCollectionViewWaterfallLayout', '~> 0.8'
pod 'SMPageControl', '~> 1.2'
pod 'PPRevealSideViewController', '~> 1.1.0'
pod 'NSLogger'
pod 'CocoaAsyncSocket'
pod 'SDWebImage'
pod 'libPhoneNumber-iOS', '~> 0.7.3' 
pod 'CrittercismSDK', '~> 4.1.2' 

post_install do | installer |
 
  # FRAMEWORK_SEARCH_PATHS
  workDir = Dir.pwd
  xcconfigFilename = "#{workDir}/Pods/Pods.xcconfig"
  xcconfig = File.read(xcconfigFilename)
  newXcconfig = xcconfig.gsub(/FRAMEWORK_SEARCH_PATHS = "/, "FRAMEWORK_SEARCH_PATHS = $(inherited) \"")
  File.open(xcconfigFilename, "w") { |file| file << newXcconfig }
 
  # HEADER_SEARCH_PATHS に $(inherited) を追加する
  workDir = Dir.pwd
  xcconfigFilename = "#{workDir}/Pods/Pods.xcconfig"
  xcconfig = File.read(xcconfigFilename)
  newXcconfig = xcconfig.gsub(/HEADER_SEARCH_PATHS = "/, "HEADER_SEARCH_PATHS = $(inherited) \"")
  File.open(xcconfigFilename, "w") { |file| file << newXcconfig }
   
  # LIBRARY_SEARCH_PATHS
  workDir = Dir.pwd
  xcconfigFilename = "#{workDir}/Pods/Pods.xcconfig"
  xcconfig = File.read(xcconfigFilename)
  newXcconfig = xcconfig.gsub(/LIBRARY_SEARCH_PATHS = "/, "LIBRARY_SEARCH_PATHS = $(inherited) \"")
  File.open(xcconfigFilename, "w") { |file| file << newXcconfig }


end
