# Configure JioMatrixTranslationiOSUIKit inside your app


## Project Settings

### Info.plist Changes

Please add below permissions keys to your `Info.plist` file with proper description.

```swift
<key>NSContactsUsageDescription</key>
<string>Allow access to Contacts display your contacts for calling</string>
<key>NSMicrophoneUsageDescription</key>
<string>Allow access to mic for recordings</string>
```

## Integration Steps

### Add SDK

Please add below pod to your Podfile and run command `pod install --repo-update --verbose`.

```ruby
pod 'JioMatrixTranslationSDK', '~> 0.1.0-alpha1'
```

Also please add this lines in your pod file if you're facing any issues.

```swift
post_install do |installer|
  installer.generated_projects.each do |project|
    project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
        config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
      end
    end
  end
end
```

### Import SDK

Please use below import statements

```swift
import JioMatrixTranslationSDK
```

### Integrate Translation View

Create instance of `JMTranslationView`.

```swift
private var translationView = JMTranslationView()
```

Add it to your viewController view.

```swift
translationView.translatesAutoresizingMaskIntoConstraints = false
view.addSubview(translationView)

NSLayoutConstraint.activate([
    translationView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
    translationView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
    translationView.topAnchor.constraint(equalTo: view.topAnchor),
    translationView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
])
```

### Initialisation


```swift
let config = JMTranslationConfig(speechKey: SPEECH_KEY, speechRegion: SPEECH_REGION, textTranslationKey: TEXT_TRANSLATION_KEY)
translationView.setUpTranslationScreen(webToken: YOUR_TOKEN, config: config)

```
