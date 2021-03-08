# Post-List-App
This project will be an app created to show case my skills,  is an app that shows a list of posts from different users and handles sources local sources for offline and remote sources for online requests.

This codebase supports only iOS platform minimum OS version iOS 14

Orientations Portrait
![optimized](https://user-images.githubusercontent.com/31734131/110271321-29561600-7f9e-11eb-8c8f-96a39f189f45.gif)


Project Setup
----
This project uses cocoapods and a podfile.lock cloning de repo and running pod install should do that being said is you can get the project to run feel free to leave a comment with you contact info and i can step and take a look.

Architecture
------
In my projects i always try to get as much separation of the domains of an app i can i this particular app i used a mix of MVVM and MVP using viewModels to make the view independent of my model also used the rule of dependency inversion creatig a comunication flow as follows View -> ViewController -> View Model -> Presenter < - Data Provider Abstraction -> Provider implementation.

Also in this project we used most of apples new api adding the power of combine implementations to hanlde asynchronous events un the app domain also using DiffableDataSource to load tableviewscells in a better way.

Third Party
-------
  - Anchorage: This library helps with the layout for the app making autolayout easy to use.
  - Alamofire: Used with combine to handle url request.
  - SkeletonView: with these library we could create a beautiful loading animation.
  - couchlite: with these library we use to save our users and post information to avoid making a lot of network request.
 
 ScreenShots 
 --------
 ![Simulator Screen Shot - iPhone 8 - 2021-03-07 at 22 58 07](https://user-images.githubusercontent.com/31734131/110271023-8f8e6900-7f9d-11eb-8e83-5e9bdf5b50e0.png)
 
 ![Simulator Screen Shot - iPhone 8 - 2021-03-07 at 22 58 21](https://user-images.githubusercontent.com/31734131/110271014-8ac9b500-7f9d-11eb-9c04-5e5169f47e11.png)
