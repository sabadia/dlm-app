Pod::Spec.new do |s|
  s.name             = 'dlm_platform'
  s.version          = '0.1.0'
  s.summary          = 'macOS window chrome (glass and vibrancy) for dlm.'
  s.description      = 'Native window effects behind the dlm_platform WindowChrome interface.'
  s.homepage         = 'https://github.com/sabadia/dlm-app'
  s.license          = { :type => 'Apache-2.0' }
  s.author           = { 'sabadia' => 'https://github.com/sabadia' }
  s.source           = { :path => '.' }
  s.source_files     = 'dlm_platform/Sources/dlm_platform/**/*'
  s.dependency 'FlutterMacOS'
  s.platform         = :osx, '13.0'
  s.swift_version    = '5.9'
end
