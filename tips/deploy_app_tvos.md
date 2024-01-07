- Install Xcode
- Fix xcodebuild path
    sudo xcode-select -s /Applications/Xcode.app/Contents/Developer/
- Register apple developer, just confirm the agreement (dont enroll developer program)
- Create empty xcode project, then save and open the project `project.pbxproject` to find the DEVELOPER_TEAM
    eg: 				DEVELOPMENT_TEAM = G98YJQ8RHP;
- Use a new bundle identifier
    com.akio.RetroArch
