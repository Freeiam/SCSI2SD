//
//  SettingsController.m
//  scsi2sd
//
//  Created by Gregory Casamento on 12/3/18.
//  Copyright © 2018 Open Logic. All rights reserved.
//

#import "SettingsController.hh"

@interface SettingsController ()

@property (nonatomic) IBOutlet NSButton *enableSCSITerminator;
@property (nonatomic) IBOutlet NSPopUpButton *speedLimit;
@property (nonatomic) IBOutlet NSTextField *startupDelay;
@property (nonatomic) IBOutlet NSTextField *startupSelectionDelay;
@property (nonatomic) IBOutlet NSButton *enableParity;
@property (nonatomic) IBOutlet NSButton *enableUnitAttention;
@property (nonatomic) IBOutlet NSButton *enableSCSI2Mode;
@property (nonatomic) IBOutlet NSButton *respondToShortSCSISelection;
@property (nonatomic) IBOutlet NSButton *mapLUNStoSCSIIDs;
@property (nonatomic) IBOutlet NSButton *enableGlitch;
@property (nonatomic) IBOutlet NSButton *enableCache;
@property (nonatomic) IBOutlet NSButton *enableDisconnect;

@end

@implementation SettingsController

- (NSString *) toXml
{
    BoardConfig config = [self getConfig];
    std::string s = SCSI2SD::ConfigUtil::toXML(config);
    NSString *string = [NSString stringWithCString:s.c_str() encoding:NSUTF8StringEncoding];
    return string;
}

/*
- (void) fromXml: (NSXMLElement *)node
{
    NSLog(@"fromXml");
}
*/
- (void) awakeFromNib
{
    self.enableParity.toolTip = @"Enable error correction parity.";
    self.enableUnitAttention.toolTip = @"Enable UNIT Attention code.";
    self.enableSCSI2Mode.toolTip = @"Enable SCSI2 Mode";
    self.enableSCSITerminator.toolTip = @"Terminate SCSI connection";
    self.enableGlitch.toolTip = @"Enable glitch mode";
    self.enableCache.toolTip = @"Enable cache";
    self.enableDisconnect.toolTip = @"Enable SCSI disconnection";
    self.respondToShortSCSISelection.toolTip = @"Respond to short SCSI selection command";
    self.mapLUNStoSCSIIDs.toolTip = @"Map Logical Units to SCSIIDs";
    self.startupDelay.toolTip = @"Delay for startup of device";
    self.speedLimit.toolTip = @"Transfer rate";
    self.startupSelectionDelay.toolTip = @"Delay between selection command and selection of device.";
}

- (void) setConfig: (BoardConfig)config
{
    // NSLog(@"setConfig");
    self.enableParity.state = (config.flags & CONFIG_ENABLE_PARITY) ? NSOnState : NSOffState;
    self.enableUnitAttention.state = (config.flags & CONFIG_ENABLE_UNIT_ATTENTION) ? NSOnState : NSOffState;
    self.enableSCSI2Mode.state = (config.flags & CONFIG_ENABLE_SCSI2) ? NSOnState : NSOffState;
    self.enableSCSITerminator.state = (config.flags & S2S_CFG_ENABLE_TERMINATOR) ? NSOnState : NSOffState;
    self.enableGlitch.state = (config.flags & CONFIG_DISABLE_GLITCH) ? NSOnState : NSOffState;
    self.enableCache.state = (config.flags & CONFIG_ENABLE_CACHE) ? NSOnState : NSOffState;
    self.enableDisconnect.state = (config.flags & CONFIG_ENABLE_DISCONNECT) ? NSOnState : NSOffState;
    self.respondToShortSCSISelection.state = (config.flags & CONFIG_ENABLE_SEL_LATCH) ? NSOnState : NSOffState;
    self.mapLUNStoSCSIIDs.state = (config.flags & CONFIG_MAP_LUNS_TO_IDS) ? NSOnState : NSOffState;
    self.startupDelay.intValue = config.startupDelay;
    self.startupSelectionDelay.intValue = config.selectionDelay;
    [self.speedLimit selectItemAtIndex: config.scsiSpeed];
}

- (void) setConfigData:(NSData *)data
{
    BoardConfig config;
    const void *bytes;
    bytes = [data bytes];
    memcpy(&config, bytes, sizeof(BoardConfig));
    [self setConfig: config];
}

- (BoardConfig) getConfig
{
    BoardConfig config;
    // NSLog(@"getConfig");
    config.flags |= self.enableSCSITerminator.intValue;

    config.flags =
        (self.enableParity.state == NSOnState ? CONFIG_ENABLE_PARITY : 0) |
        (self.enableUnitAttention.state == NSOnState ? CONFIG_ENABLE_UNIT_ATTENTION : 0) |
        (self.enableSCSI2Mode.state == NSOnState ? CONFIG_ENABLE_SCSI2 : 0) |
        (self.enableGlitch.state == NSOnState ? CONFIG_DISABLE_GLITCH : 0) |
        (self.enableCache.state == NSOnState ? CONFIG_ENABLE_CACHE: 0) |
        (self.enableDisconnect.state == NSOnState ? CONFIG_ENABLE_DISCONNECT: 0) |
        (self.respondToShortSCSISelection.state == NSOnState ? CONFIG_ENABLE_SEL_LATCH : 0) |
        (self.mapLUNStoSCSIIDs.state == NSOnState ? CONFIG_MAP_LUNS_TO_IDS : 0) |
        (self.enableSCSITerminator.state == NSOnState ? S2S_CFG_ENABLE_TERMINATOR : 0);
    config.startupDelay = self.startupDelay.intValue;
    config.selectionDelay = self.startupSelectionDelay.intValue;
    config.scsiSpeed = self.speedLimit.indexOfSelectedItem;
    
    return config;
}

@end
