Pod::Spec.new do |s|
    s.name         = 'CLPhotoWall'
    s.version      = ‘1.0.0’
    s.summary      = 'An easy way to use pull-to-refresh'
    s.homepage     = 'https://github.com/qcl901028/CLPhotoWall'
    s.license      = 'MIT'
    s.authors      = {'qcl901028' => ‘qcl901028@gmail.com'}
    s.platform     = :ios, ‘8.0’
    s.source       = {:git => 'https://github.com/qcl901028/CLPhotoWall.git', :tag => s.version}
    s.source_files = 'PhotoKit/**/*.{h,m,png}’
    s.requires_arc = true
end
