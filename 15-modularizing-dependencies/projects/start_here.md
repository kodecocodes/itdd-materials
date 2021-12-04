In order to run the projects in this section you will to run the included to supply a test API for the app to connect to. 

## Installation

This is a **Vapor** project written in Swift. In order to run the backend, you'll first have to install Vapor.

To install, Follow the instructions here at: https://docs.vapor.codes/4.0/install/

## Build

First, build the project to have xcode build the app and download the packages. 

From the `MyBiz` folder

```
> vapor build
```

## Run the backend

You can then run the backend code.

From the command line navigate to the `backend\MyBiz` folder in these materials. 
Then, from that folder just run:

```
> vapor run
```

## Troubleshooting
If you need to fix up some errors (say Swift has changed in a new version), Vapor can generate an Xcode project from the folder to make it easier to edit the files:

```
> vapor xcode
```
