# How to use Unity 3D within an iOS app

This is going to appear to be complicated based on the length of this article
it's really not. I try to fully show some examples here, and provide some images
for those who may not know where certain things are in xcode.


This would not be possible without [www.the-nerd.be],  Frederik Jacques.
All of the settings in the xcconfig file, the `UnityProjectRefresh.sh`
script and the project import are directly derieved from his work. The video
he made in the provided link is worth watching.

This covers Unity 5+. At the time of this writing this has been
successfully used with Unity `5.2.2f1` and `Swift 2.1` under `Xcode 7.1` & `Swift 3.0` under `Xcode 8.0`.

This works with storyboards.

You only get **ONE** unity view. You **CANNOT** run multiple Unity
Views in your application at once. You will also need a way to
communicate to <-> from your unity content to your iOS app.
I would recommend an event bus in both your Unity code and
your iOS code. AKA one central place on both sides to emit events
to and listen to events on each side.

In other words you will need 2 busses, 1 on the Unity side that you can
call into to emit events from on the iOS side, and one on the iOS side that
Unity can call into to emit events on.

You can read more about communication between the 2 worlds from
the following links:

**More about embedding**

http://forum.unity3d.com/threads/unity-appcontroller-subclassing.191971/

Specifically there is a bit on commuicating here with some sample code.
Note, this is not for UNITY 5, but it shows the samples in OverlayUI related
making functions available to the Objective-C side of things to be called from
your Unity Code.

http://forum.unity3d.com/threads/unity-appcontroller-subclassing.191971/#post-1341666


**Communicating from Unity -> ObjC**

http://blogs.unity3d.com/2015/07/02/il2cpp-internals-pinvoke-wrappers/

http://forum.unity3d.com/threads/unity-5-2-2f1-embed-in-ios-with-extern-dllimport-__internal-methods-fails-to-compile.364809/


**Communicating from Unity <-> ObjC**

http://alexanderwong.me/post/29861010648/call-objective-c-from-unity-call-unity-from


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
the `UnityProjectRefresh.sh` script make this easier.

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
- Rename `main` in `main.mm` to anything else
- Alter the application delegate and create a main.swift file.
- Wrap the UnityAppController into your application delegate
- Adjust the `GetAppController` function in `UnityAppController.h`
- Go bananas, you did it! Add the unity view wherever you want!

#### Add the Unity.xcconfig file provided in this repo

Drag and drop the `Unity.xcconfig` file into your Xcode project.
Set the project to use those settings.

<img src="https://dl.dropboxusercontent.com/u/20065272/forums/github/ios-unity5/set_xcconfig.png">

#### Adjust 1 project dependent setting
So that does a lot for you in terms of configuration, now we need to adjust 1 setting in it.
Since we don't know where you decided to export your unity project too, you need to configure that.


Open up your project's build settings and scroll all the way to bottom, you will see:

```
UNITY_IOS_EXPORT_PATH
```

Adjust that path to point to your ios unity export path


<img src="https://dl.dropboxusercontent.com/u/20065272/forums/github/ios-unity5/unity_ios_export_path.png">

You can also adjust your

```
UNITY_RUNTIME_VERSION
```

If you are not using  `5.2.2f1`.


#### Add a new `run script` build phase

Now we need to ensure we copy our fresh unity project on each build, so we add a
new run script build phase.

Select Build Phases from your project settings to add a new build phase.

Copy the contents of the UnityProjectRefresh.sh script into this phase.

<img src="https://dl.dropboxusercontent.com/u/20065272/forums/github/ios-unity5/run_script_phase.png">


#### Import your unity project

This is outlined in this [www.the-nerd.be] video at around 5:35 - 7:30 as well, but it's now time to import our Unity project.

Create a new group and call it `Unity`, the name doesn't matter it's just helpful to name things so you know what they are).
<img src="https://dl.dropboxusercontent.com/u/20065272/forums/github/ios-unity5/new_group.png">

You will need to open the folder you built your Unity iOS project into. It will be the same folder you
specified for the `UNITY_IOS_EXPORT_PATH` above.

Do 1 folder at a time, this will take a minute or more to do, there are lots of files.

We are going to drag in the following folders (You don't need to copy them):

- `/your/unity/ios/export/path/Classes`
- `/your/unity/ios/export/path/Libraries`


#### Clean up your unity project

This is all in the [www.the-nerd.be] video as well 7:35 -
There is two location we will clean up for convenience. For both of these we
*ONLY WANT TO REMOVE REFERENCES DO NOT MOVE TO TRASH*

We don't need the `Unity/Classes/Native/*.h`  and we don't need `Unity/Libraries/libl2cpp/`.

The Unity.xcconfig we applied knows where they are for compiling purposes.

- Remove `Unity/Libraries/libl2cpp/` 7:35 - 7:50 in [www.the-nerd.be] video.
- Remove `Unity/Classes/Native/*.h` 7:55- 8:44 in [www.the-nerd.be] video.


#### Add the `objc` folder in this repo

You can copy these if you want, they are tiny.

- `UnityBridge.h` is the `SWIFT_OBJC_BRIDGING_HEADER` specified in `Unity.xcconfig`
- `UnityUtils.h/mm` is our new custom init function.

The new custom unity init function is pulled directly our of the main.mm file in your unity project.
Swift does not have the same initialization convention as an objecitve-c app, so we are going to
tweak things slightly.

#### Rename `main` in `main.mm` to anything else

In your xcode project under `Unity/Classses` locate the `main.mm` file. Within that file locate

```cpp
int main(int argc, char* argv[])
```
Once you find that you can go ahead and see that `UnityUtils.mm`, which we imported
above, is effectively this function. Should Unity change this initialization you will need
to update your `UnityUtils.mm` file to match their initialization. Note that we don't
copy the `UIApplicationMain` part. Swift will handle that.

Anyway, we need to rename this function to anything but `main`:


```cpp
int main_unity_default(int argc, char* argv[])
```

#### Alter the swift application delegate and create a main.swift file

We have to get our initialization point done however, so we need some small additions/changes.

Open your `AppDelegate.swift` you will see this at the top of the file:

```swift
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
```

All we are going to do is remove `@UIApplicationMain` so we
are left with the following after we are done:

```swift
class AppDelegate: UIResponder, UIApplicationDelegate {
```

Now we need to let xcode know where our new main is. Go ahead and create
a new swift file called `main.swift`. Paste this into it:

```swift
import Foundation
import UIKit

// overriding @UIApplicationMain
// http://stackoverflow.com/a/24021180/1060314

custom_unity_init(CommandLine.argc, CommandLine.unsafeArgv)
let newUnsafeArgv = UnsafeMutableRawPointer( CommandLine.unsafeArgv ).bindMemory( to: UnsafeMutablePointer<Int8>.self, capacity: Int( CommandLine.argc ) )
UIApplicationMain( CommandLine.argc, newUnsafeArgv , NSStringFromClass( UIApplication.self ), NSStringFromClass( AppDelegate.self ) )
```

Assuming your bridging header is properly registered, xcode will NOT be
complaining about `custom_unity_init`. If it is, something is wrong with the
bridging header registration. Go check that out.

Note that if your `AppDelegate` is NOT called `AppDelegate` you will need to update
the last  argument above in `UIApplicationMain(<argc>, <argv>, <UIApplication>, <here>)`
to be whatever yours is called.

#### Wrap the UnityAppController into your application delegate

We are taking away control from the unity generated application delegate, we
need to act as a proxy for it in our `AppDelegate`.

First add the following variable to your `AppDelegate`

```swift
var currentUnityController: UnityAppController!
```
Now we need to initialize and proxy through the calls to the `UnityAppController`.
All said and done you will be left with the following:

```swift
//
//  AppDelegate.swift
//
//  Created by Adam Venturella on 10/28/15
//

import UIKit

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var currentUnityController: UnityAppController!


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        currentUnityController = UnityAppController()
        currentUnityController.application(application, didFinishLaunchingWithOptions: launchOptions)
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        currentUnityController.applicationWillResignActive(application)
    }

    func applicationDidEnterBackground(application: UIApplication) {
        currentUnityController.applicationDidEnterBackground(application)
    }

    func applicationWillEnterForeground(application: UIApplication) {
        currentUnityController.applicationWillEnterForeground(application)
    }

    func applicationDidBecomeActive(application: UIApplication) {
        currentUnityController.applicationDidBecomeActive(application)
    }

    func applicationWillTerminate(application: UIApplication) {
        currentUnityController.applicationWillTerminate(application)
    }
}

```

#### Adjust the `GetAppController` function in `UnityAppController.h`

Locate the file `UnityAppController.h` in the xcode group `Unity/Classes/`

Find the following function:

```objc
inline UnityAppController*GetAppController()
{
    return (UnityAppController*)[UIApplication sharedApplication].delegate;
}
```

Comment that out. You will end up with this:

```objc
//inline UnityAppController*GetAppController()
//{
//    return (UnityAppController*)[UIApplication sharedApplication].delegate;
//}
```

Now we need to add a new version of this function:

```objc
NS_INLINE UnityAppController* GetAppController()
{
    NSObject<UIApplicationDelegate>* delegate = [UIApplication sharedApplication].delegate;
    UnityAppController* currentUnityController = (UnityAppController *)[delegate valueForKey:@"currentUnityController"];
    return currentUnityController;
}
```


#### Go bananas, you did it! Add the unity view wherever you want!

I happen to do this in a stock, single view application, so xcode generated a `ViewController.swift`
file for me attached to a storyboard. Here is how I hooked up my little demo:

```swift
//
//  ViewController.swift
//
//  Created by Adam Venturella on 10/28/15.
//

import UIKit

class ViewController: UIViewController {

    @IBAction func onLoadUnity(sender: AnyObject) {
        loadUnity()
    }

    @IBAction func onCallUnity(sender: AnyObject) {
        UnitySendMessage("EventBus", "Trigger", "Hello World")
    }

    func loadUnity(){

        let unityView = UnityGetGLView()

        self.view.addSubview(unityView)
        unityView.translatesAutoresizingMaskIntoConstraints = false

        // look, non-full screen unity content!
        let views = ["view": unityView]
        let w = NSLayoutConstraint.constraintsWithVisualFormat("|[view]-20-|", options: [], metrics: nil, views: views)
        let h = NSLayoutConstraint.constraintsWithVisualFormat("V:|-75-[view]-50-|", options: [], metrics: nil, views: views)

        view.addConstraints(w + h)
    }
}

```

[www.the-nerd.be]: http://www.the-nerd.be/2015/08/20/a-better-way-to-integrate-unity3d-within-a-native-ios-application/  "The Nerd"
