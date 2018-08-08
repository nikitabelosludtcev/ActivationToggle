Pod::Spec.new do |s|
s.name         = 'ActivationToggle'
s.version      = '0.1.0'
s.summary      = 'Toggle control that transforms to checkmark on activation.'
s.homepage     = 'https://github.com/nikitabelosludtcev/ActivationToggle'
s.license      = { :type => 'Apache', :file => 'LICENSE' }
s.authors      = { 'Nikita Belosludtcev' => 'nbelosludtcev@gmail.com' }
s.source       = { :git => 'https://github.com/nikitabelosludtcev/ActivationToggle.git', :tag => s.version.to_s }
s.ios.deployment_target = '8.0'
s.source_files = 'ActivationToggle/Classes/**/*'
s.framework    = 'UIKit'
s.requires_arc = true
end

