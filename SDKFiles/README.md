Box Objective-C SDK
---------------

You can use the Box.com API to create applications and websites that integrate with Box.com and can perform the following functions:

* Manage Login
* Store and retrieve files from Box.com
* Organize files into folders
* Move, rename and delete files
* Share files
* Browse files

### Setup ###

1. Download BoxAPI folder
2. Copy BoxAPI/Classes/SDKFiles into your project
3. Select 'Copy items into destination group's folder (if needed)'. Select 'Create groups for any added folders'. Ensure that you are adding it to all the relevant targets.
4. Click Finish
5. Go to your Project->[the relevant target]->Build Phases->Link Binary With Libraries to add a framework
6. Click the + button and add Security.framework
7. Open in Xcode SDKFiles->BoxAPIKey.h
8. Enter your API key as an NSString and remove the #warning line. If you do not have an API Key, you can obtain one from http://developers.box.net/
9. At this point, your project should build with no errors or warnings. If you are having difficulty at this point, please ping us on our [forum](http://forum.developers.box.net/box_developers) or email us directly at developers[at]box[dot]net.

### Usage ###

#### Sample App ####

A sample app is provided that includes code to present a login view controller and execute most of the actions in the API.

#### Login ####

The following code returns a BoxLoginViewController:

<code>BoxLoginViewController * vc = [BoxLoginViewController loginViewControllerWithNavBar:YES]; //Since YES was passed in here, the view controller MUST be presented modally.
vc.boxLoginDelegate = self;
[self presentModalViewController:vc animated:YES];</code>

This view controller includes a UINavigationBar, so must be presented modally. Alternatively, you can pass NO in as a parameter and it will return a UIViewController which can be presented using any method (but does not include a UINavigationBar).
The delegate must implement the method:

<code>- (void)boxLoginViewController:(BoxLoginViewController *)boxLoginViewController didFinishWithResult:(LoginResult)result;</code>

The BoxLoginViewController does not dismiss itself automatically, so this method must dismiss it.
Optionally, the delegate can implement the method:

<code>- (BOOL)boxLoginViewController:(BoxLoginViewController*)boxLoginViewController shouldDisplayError:(NSError*)error;</code>

If this method returns false, then you are responsible for providing an error message using your own styling. If this method is not implemented, or returns true, a UIAlertView is used.

#### API Call ####

Here is example code which creates a new folder in the root folder:

<code>BoxCreateFolderOperation * createFolderOp = [BoxCreateFolderOperation operationForFolderName:self.textView.text parentID:@"0" share:NO];
OperationCompletionHandler block = ^(BoxOperation * op, BoxOperationResponse response) { 
	//Contains the code to be run on completion of the operation. Though the operation is run asynchronously, this code will run in the main thread.
};
[[BoxNetworkOperationManager sharedBoxOperationManager] sendRequest:createFolderOp onCompletetion:block]; </code>

Here @"0" refers to the root folder. The code is the same for all the different operations except for the first line (where a different type of operation is used). The operations provided are:

* Add Comments (BoxAddCommentsOperation)
* Create Folder (BoxCreateFolderOperation)
* Delete Comments (BoxDeleteCommentsOperation)
* Delete file/folder (BoxDeleteOperation)
* Download files (BoxDownloadOperation)
* Get Comments (BoxGetCommentsOperation)
* Get Updates (BoxGetUpdatesOperation)
* Move file/folder (BoxMoveOperation)
* Share (BoxPublicShareOperation, BoxPublicUnshareOperation)
* Rename file/folder (BoxRenameOperation)
* Upload (BoxUploadOperation)

#### Get Folder ####

There is no operation for getting a folder. Instead, the following code is used:

<code>GetFolderCompletionHandler block = ^(BoxFolder* folder, BoxFolderDownloadResponseType response) {
	//Contains the code to be run when the folder has been retrieved. Though the operation is run asynchronously, this code will run in the main thread.
};
[[BoxNetworkOperationManager sharedBoxOperationManager] getBoxFolderForID:@"0" onCompletion:block]; </code>

In this code, @"0" is passed in as the folderID which refers to the root folder.

#### Browse Files ####

The SDK provides a BoxBrowserTableViewController for browsing files and folders. It is recommended that you subclass this class to override the functionality you desire. To initialize the object, use the following code:

<code>BoxBrowserTableViewController * browserTableViewController = [[BoxBrowserTableViewController alloc] initWithFolderID:@"0"];</code>

Here, @"0" is used to designate the root folder. Then, the browserTableViewController must be used inside of a UINavigationViewController. To subclass BoxBrowserTableViewController, we recommend that you at least override the following methods:

<code>- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    return cell;
}
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    // Insert code here for the action that should be performed when the accessory button is pressed.
}</code>

The first method adds a disclosure button to the cells to register an action (because selecting a folder will open the folder). The second method handles the action that should be performed when the disclosure button is pressed. By default, - (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath is reserved for selecting folders to open them (on files, it does nothing), but feel free to override this function if you desire different functionality. The sample app has several examples of how this class can be subclassed (see most of the actions).

### Documentation ###

You can find complete documentation at [http://developers.box.net/](http://developers.box.net/)

### Support ###

If you have any questions or suggestions for improvement, ping us on our [forum](http://forum.developers.box.net/box_developers) or email us directly at developers[at]box[dot]net.
