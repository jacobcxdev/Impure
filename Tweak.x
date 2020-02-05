#include <UIKit/UIKit.h>
#include <AVFoundation/AVFoundation.h>

static UIImage *image;
static UIAlertAction *cameraAction;
static void (^cameraHandler)(UIAlertAction *action);

@interface _TtC4Pure18ChatViewController : UIViewController<UIImagePickerControllerDelegate>
@end

@interface UIAlertAction ()
@property (nonatomic, copy, readwrite) void (^handler)(UIAlertAction *action);
@end

%hook _TtC4Pure18ChatViewController
- (void)presentViewController:(UIAlertController *)arg1 animated:(BOOL)arg2 completion:(void (^)(void))arg3 {
	if ([arg1 isKindOfClass:[UIAlertController class]]) {
		NSMutableArray *titles = [[NSMutableArray alloc] init];
		for (UIAlertAction *action in [arg1 actions]) {
			[titles addObject:action.title];
			if ([action.title isEqual:@"Camera"]) {
				cameraAction = action;
				cameraHandler = action.handler;
			}
		}
		if ([titles indexOfObject:@"Camera"] != NSNotFound && [titles indexOfObject:@"Location"] != NSNotFound && cameraAction) {
			UIAlertAction *action = [UIAlertAction actionWithTitle:@"Select Image" style:0 handler:^(UIAlertAction *action) {
				UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
				imagePicker.delegate = (id)self;
				imagePicker.allowsEditing = true;
				imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
				[self presentViewController:imagePicker animated:true completion:nil];
			}];
			[arg1 addAction:action];
		}
	}
	return %orig;
}
%new
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	image = info[UIImagePickerControllerEditedImage];
    [picker dismissViewControllerAnimated:true completion:nil];
	if (![[NSUserDefaults standardUserDefaults] boolForKey:@"hideImpureInstructions"]) {
		UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Impure Instructions" message:@"It is important that you select the REAR camera by tapping the button in the TOP LEFT when you take the photo, otherwise the image will be rotated 90º anticlockwise." preferredStyle:UIAlertControllerStyleAlert];
		UIAlertAction *okay = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
			if (cameraAction && cameraHandler) cameraHandler(cameraAction);
		}];
		UIAlertAction *notAgain = [UIAlertAction actionWithTitle:@"Don't show again" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
			[[NSUserDefaults standardUserDefaults] setObject:@"true" forKey:@"hideImpureInstructions"];
			[[NSUserDefaults standardUserDefaults] synchronize];
			if (cameraAction && cameraHandler) cameraHandler(cameraAction);
		}];
		[alert addAction:okay];
		[alert addAction:notAgain];
		alert.preferredAction = okay;
		[self presentViewController:alert animated:true completion:nil];
	} else {
		if (cameraAction && cameraHandler) cameraHandler(cameraAction);
	}
}
%end

%hook AVCapturePhotoOutput
+ (NSData *)JPEGPhotoDataRepresentationForJPEGSampleBuffer:(void *)arg2 previewPhotoSampleBuffer:(void *)arg3 {
	if (image) return UIImageJPEGRepresentation(image, 1);
	else return %orig;
}
%end

%ctor {
	NSLog(@"Impure loaded");
	[[NSUserDefaults standardUserDefaults] setObject:@"false" forKey:@"hideImpureInstructions"];
}