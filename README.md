# VolumeControl

VolumeControl is a custom volume control for iPhone featuring a well-designed round slider.

## Preview
<img src="https://github.com/12Rockets/VolumeControl/blob/master/VolumeControl.gif" width="250">

## Usage

```objc
// Include VolumeControl.h into your ViewController.
// Don’t forget to set your delegate:
@interface ViewController () <VolumeControlDelegate>



@property (nonatomic, strong)VolumeControl *control; 



self.control = [[VolumeControl alloc] initWithCenter:CGPointMake(screen.size.width, screen.size.height)

                                              withRadius:screen.size.width*0.50

                                              withVolume:self.volume/100

                                   withVolumeControlDelegate:self];

[self.myView addSubview: control]; 



// VolumeControl animates from the bottom-right corner of the screen thus it will need either the UIButton or UIView to show the controller.

- (IBAction)onVolumeButton:(id)sender {

[self.control setHidden:NO];

}
```
## Credit
Designed and developed by [12Rockets](http://12rockets.com/).

### Development

* [Marko Cancar](https://github.com/marko-cancar)

### Design

* [Maja Savic](https://github.com/majasavic)
* [Nikola Zivanovic](https://github.com/therandoman)

---
## Feedback
Send us your feedback at hello@12rockets.com or hit us up on [Twitter](https://twitter.com/TwelveRockets).


## License
This projected is licensed under the terms of the MIT License (MIT) License. See LICENSE.txt for more details.
