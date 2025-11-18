#!/bin/sh

# Function to clean and get Flutter packages
clean_flutter() {
    flutter clean
    flutter pub get
}

# Function to clean and reinstall iOS pods
clean_pods() {
    cd ios
    pod deintegrate
    pod install
    cd ..
}

clean_ios(){
    flutter clean
    rm -rf ios/Pods ios/Podfile.lock ios/.symlinks ios/Flutter/Flutter.podspec
    flutter pub get
    cd ios
    pod install --repo-update
    cd ..
}

# Function to update Cocoapods
update_cocoapods() {
    sudo gem install cocoapods
    pod setup
}

# Main script execution
clean_flutter
clean_pods
update_cocoapods

# Update pod repo and install pods
cd ios
pod install --repo-update
cd ..

# Final Flutter clean and get packages
clean_flutter

# Run the Flutter app
flutter run