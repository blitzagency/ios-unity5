# How to use Unity 3D within an iOS app


This would not be possible without [the-nerd] (Frederik Jacques).
All of the settings in the xcconfig file, the `UnityProjectInstall.sh`
script and the project import are directly derieved from his work. The video
he made in the provided link is worth watching.


This covers Unity 5+. At the time of this writing this has been
successfully used with Unity `5.2.2f1` and `Swift 2.1` under `Xcode 7.1`.


## Lets get started.

### From Unity

First you need to have a project in unity, and you need to build it for iOS.

Under Unity 5 the project's scripting backend is already set to `il2cpp` so you
pretty much just have to :

- `File -> Build Settings`
- Select your scene(s)
- Press the build button
- Remember the folder you built the project too.


### From Xcode

There is a bit more to do here, but ideally the `Unity.xcconfig` and
the `UnityProjectInstall.sh` script make this easier.

Setting expectations, the project import process here takes some time,
it's not instant, Unity generates a lot of files and Xcode has to import them
all. So expect to stare a beachball for a few minuts while it does it's thing.

Ok! Fire up Xcode and create a new `Swift` project or open an existing
`Swift` project.

Here is what we will be doing, this will seem like a lot, but it's pretty straight
forward. You will fly through these steps minus the unity project import/cleanup
which is not diffiucilt, it's just time consuming given the number of files.

- Add the Unity.xcconfig file provided in this repo
- Adjust 1 project dependent setting
- Add a new `run script` build phase
- Import your unity project
- Clean up your unity project
- Add the `objc` folder in this repo with the new custom unity init and obj-c bridging header
- Alter the application delegate and cerate a main.swift file.
- Rename `main` in `main.mm` to anything else
- Adjust the `GetAppController` function in `UnityAppController.h`


#### Add the Unity.xcconfig file provided in this repo

Drag and drop the `Unity.xcconfig` file into your Xcode project.
Set the project to use those settings.

<img src="https://dl.dropboxusercontent.com/u/20065272/forums/github/ios-unity5/set_xcconfig.png">



Now, remember the last step from Unity above? `Remember the folder you built the project too.`.
Good, we need to drag some files into our

[the-nerd]: http://www.the-nerd.be/2015/08/20/a-better-way-to-integrate-unity3d-within-a-native-ios-application/  "The Nerd"
