//
//  CCLocalStorage.m
//  Crypto Cloud Technology Nextcloud
//
//  Created by Marino Faggiana on 16/01/17.
//  Copyright (c) 2017 TWS. All rights reserved.
//
//  Author Marino Faggiana <m.faggiana@twsweb.it>
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

#import "CCLocalStorage.h"
#import "AppDelegate.h"

#ifdef CUSTOM_BUILD
#import "CustomSwift.h"
#else
#import "Nextcloud-Swift.h"
#endif

@interface CCLocalStorage ()
{
    NSArray *dataSource;
}
@end

@implementation CCLocalStorage

-  (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])  {
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeTheming) name:@"changeTheming" object:nil];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Custom Cell
    [self.tableView registerNib:[UINib nibWithNibName:@"CCLocalStorageCell" bundle:nil] forCellReuseIdentifier:@"Cell"];

    // dataSource
    dataSource = [NSMutableArray new];
    
    // Metadata
    _metadata = [CCMetadata new];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 1)];
    self.tableView.separatorColor = [NCBrandColor sharedInstance].seperator;
    self.tableView.emptyDataSetDelegate = self;
    self.tableView.emptyDataSetSource = self;
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    
    // ServerUrl
    if (!_serverUrl)
        _serverUrl = [CCUtility getDirectoryLocal];
    
    // Title
    if (_titleViewControl)
        self.title = _titleViewControl;
    else
        self.title = NSLocalizedString(@"_local_storage_", nil);
}

// Apparirà
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Color
    [app aspectNavigationControllerBar:self.navigationController.navigationBar encrypted:NO online:[app.reachability isReachable] hidden:NO];
    [app aspectTabBar:self.tabBarController.tabBar hidden:NO];
    
    // Plus Button
    [app plusButtonVisibile:true];
    
    [self reloadDatasource];
}

- (void)changeTheming
{
    if (self.isViewLoaded && self.view.window)
        [app changeTheming:self];
}

#pragma --------------------------------------------------------------------------------------------
#pragma mark ==== DZNEmptyDataSetSource ====
#pragma --------------------------------------------------------------------------------------------

- (BOOL)emptyDataSetShouldDisplay:(UIScrollView *)scrollView
{
    // only for root
    if ([_serverUrl isEqualToString:[CCUtility getDirectoryLocal]])
        return YES;
    else
        return NO;
}

- (CGFloat)spaceHeightForEmptyDataSet:(UIScrollView *)scrollView
{
    return 0.0f;
}

- (UIColor *)backgroundColorForEmptyDataSet:(UIScrollView *)scrollView
{
    return [UIColor whiteColor];
}

- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView
{
    return [UIImage imageNamed:image_localStorageNoRecord];
}

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView
{
    NSString *text = [NSString stringWithFormat:@"%@", NSLocalizedString(@"_local_storage_no_record_", nil)];
    
    NSDictionary *attributes = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:20.0f], NSForegroundColorAttributeName:[UIColor lightGrayColor]};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView
{
    NSString *text = [NSString stringWithFormat:@"\n%@", NSLocalizedString(@"_tutorial_local_view_", nil)];
    
    NSMutableParagraphStyle *paragraph = [NSMutableParagraphStyle new];
    paragraph.lineBreakMode = NSLineBreakByWordWrapping;
    paragraph.alignment = NSTextAlignmentCenter;
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:14.0], NSForegroundColorAttributeName: [UIColor lightGrayColor], NSParagraphStyleAttributeName: paragraph};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

#pragma --------------------------------------------------------------------------------------------
#pragma mark ===== UIDocumentInteractionController <delegate> =====
#pragma --------------------------------------------------------------------------------------------

- (void)documentInteractionControllerDidDismissOptionsMenu:(UIDocumentInteractionController *)controller
{
    // evitiamo il rimando della eventuale photo e/o video
    if ([CCCoreData getCameraUploadActiveAccount:app.activeAccount]) {
        
        [CCCoreData setCameraUploadDatePhoto:[NSDate date]];
        [CCCoreData setCameraUploadDateVideo:[NSDate date]];
    }
}

#pragma --------------------------------------------------------------------------------------------
#pragma mark ===== menu =====
#pragma--------------------------------------------------------------------------------------------

- (void)openModel:(CCMetadata *)metadata
{
    UIViewController *viewController;
    BOOL isLocal = YES;
    NSString *serverUrl = [CCCoreData getServerUrlFromDirectoryID:_metadata.directoryID activeAccount:app.activeAccount];
    
    if ([metadata.model isEqualToString:@"cartadicredito"])
        viewController = [[CCCartaDiCredito alloc] initWithDelegate:self fileName:metadata.fileName uuid:metadata.uuid fileID:metadata.fileID isLocal:isLocal serverUrl:serverUrl];
    
    if ([metadata.model isEqualToString:@"bancomat"])
        viewController = [[CCBancomat alloc] initWithDelegate:self fileName:metadata.fileName uuid:metadata.uuid fileID:metadata.fileID isLocal:isLocal serverUrl:serverUrl];
    
    if ([metadata.model isEqualToString:@"contocorrente"])
        viewController = [[CCContoCorrente alloc] initWithDelegate:self fileName:metadata.fileName uuid:metadata.uuid fileID:metadata.fileID isLocal:isLocal serverUrl:serverUrl];
    
    if ([metadata.model isEqualToString:@"accountweb"])
        viewController = [[CCAccountWeb alloc] initWithDelegate:self fileName:metadata.fileName uuid:metadata.uuid fileID:metadata.fileID isLocal:isLocal serverUrl:serverUrl];
    
    if ([metadata.model isEqualToString:@"patenteguida"])
        viewController = [[CCPatenteGuida alloc] initWithDelegate:self fileName:metadata.fileName uuid:metadata.uuid fileID:metadata.fileID isLocal:isLocal serverUrl:serverUrl];
    
    if ([metadata.model isEqualToString:@"cartaidentita"])
        viewController = [[CCCartaIdentita alloc] initWithDelegate:self fileName:metadata.fileName uuid:metadata.uuid fileID:metadata.fileID isLocal:isLocal serverUrl:serverUrl];
    
    if ([metadata.model isEqualToString:@"passaporto"])
        viewController = [[CCPassaporto alloc] initWithDelegate:self fileName:metadata.fileName uuid:metadata.uuid fileID:metadata.fileID isLocal:isLocal serverUrl:serverUrl];
    
    if ([metadata.model isEqualToString:@"note"]) {
        
        viewController = [[CCNote alloc] initWithDelegate:self fileName:metadata.fileName uuid:metadata.uuid fileID:metadata.fileID isLocal:isLocal serverUrl:serverUrl];
        
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
        
        [self presentViewController:navigationController animated:YES completion:nil];
        
    } else {
        
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
        
        [navigationController setModalPresentationStyle:UIModalPresentationFormSheet];
        
        [self presentViewController:navigationController animated:YES completion:nil];
    }
}

- (void)openWith:(CCMetadata *)metadata
{
    NSString *fileNamePath = [NSString stringWithFormat:@"%@/%@", _serverUrl, metadata.fileNameData];
        
    if ([[NSFileManager defaultManager] fileExistsAtPath:fileNamePath]) {
        
        [[NSFileManager defaultManager] removeItemAtPath:[NSTemporaryDirectory() stringByAppendingString:metadata.fileNamePrint] error:nil];
        [[NSFileManager defaultManager] linkItemAtPath:fileNamePath toPath:[NSTemporaryDirectory() stringByAppendingString:metadata.fileNamePrint] error:nil];
        
        NSURL *url = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingString:metadata.fileNamePrint]];
        
        _docController = [UIDocumentInteractionController interactionControllerWithURL:url];
        _docController.delegate = self;
        
        [_docController presentOptionsMenuFromRect:self.view.frame inView:self.view animated:YES];
    }
}

- (void)requestDeleteMetadata:(CCMetadata *)metadata indexPath:(NSIndexPath *)indexPath
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
    [alertController addAction: [UIAlertAction actionWithTitle:NSLocalizedString(@"_delete_", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        
        NSString *fileNamePath = [NSString stringWithFormat:@"%@/%@", _serverUrl, metadata.fileNameData];
        NSString *iconPath = [NSString stringWithFormat:@"%@/.%@.ico", _serverUrl, metadata.fileNameData];
                                                                   
        [[NSFileManager defaultManager] removeItemAtPath:fileNamePath error:nil];
        [[NSFileManager defaultManager] removeItemAtPath:iconPath error:nil];
        
                                                               
        [self reloadDatasource];
    }]];
        
        
    [alertController addAction: [UIAlertAction actionWithTitle:NSLocalizedString(@"_cancel_", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }]];
        
    alertController.popoverPresentationController.sourceView = self.view;
    alertController.popoverPresentationController.sourceRect = [self.tableView rectForRowAtIndexPath:indexPath];
        
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        [alertController.view layoutIfNeeded];
        
    [self presentViewController:alertController animated:YES completion:nil];
}

-(void)cellButtonDownWasTapped:(id)sender
{
    CGPoint touchPoint = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:touchPoint];
    CCMetadata *metadata = [CCMetadata new];
    UIImage *iconHeader;
    
    NSString *cameraFolderName = [CCCoreData getCameraUploadFolderNameActiveAccount:app.activeAccount];
    NSString *cameraFolderPath = [CCCoreData getCameraUploadFolderPathActiveAccount:app.activeAccount activeUrl:app.activeUrl];
        
    metadata = [CCUtility insertFileSystemInMetadata:[dataSource objectAtIndex:indexPath.row] directory:_serverUrl activeAccount:app.activeAccount cameraFolderName:cameraFolderName cameraFolderPath:cameraFolderPath];
        
    
    AHKActionSheet *actionSheet = [[AHKActionSheet alloc] initWithView:self.view title:nil];
    
    actionSheet.animationDuration = 0.2;
    
    actionSheet.blurRadius = 0.0f;
    actionSheet.blurTintColor = [UIColor colorWithWhite:0.0f alpha:0.50f];
    
    actionSheet.buttonHeight = 50.0;
    actionSheet.cancelButtonHeight = 50.0f;
    actionSheet.separatorHeight = 5.0f;
    
    actionSheet.automaticallyTintButtonImages = @(NO);
    
    actionSheet.encryptedButtonTextAttributes = @{ NSFontAttributeName:[UIFont systemFontOfSize:16], NSForegroundColorAttributeName:[NCBrandColor sharedInstance].cryptocloud };
    actionSheet.buttonTextAttributes = @{ NSFontAttributeName:[UIFont systemFontOfSize:16], NSForegroundColorAttributeName:[UIColor blackColor] };
    actionSheet.cancelButtonTextAttributes = @{ NSFontAttributeName:[UIFont systemFontOfSize:16], NSForegroundColorAttributeName:[NCBrandColor sharedInstance].brand };
    actionSheet.disableButtonTextAttributes = @{ NSFontAttributeName:[UIFont systemFontOfSize:16], NSForegroundColorAttributeName:[UIColor blackColor] };
    
    actionSheet.separatorColor = [NCBrandColor sharedInstance].seperator;
    actionSheet.cancelButtonTitle = NSLocalizedString(@"_cancel_",nil);
    
    // assegnamo l'immagine anteprima se esiste, altrimenti metti quella standars
    if ([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@/%@.ico", app.directoryUser, metadata.fileID]])
        iconHeader = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@.ico", app.directoryUser, metadata.fileID]];
    else
        iconHeader = [UIImage imageNamed:metadata.iconName];
    
    [actionSheet addButtonWithTitle: metadata.fileNamePrint
                              image: iconHeader
                    backgroundColor: [NCBrandColor sharedInstance].tabBar
                             height: 50.0
                               type: AHKActionSheetButtonTypeDisabled
                            handler: nil
    ];

    // Remove file/folder offline
    if (_serverUrl == nil) {
        
        [actionSheet addButtonWithTitle:NSLocalizedString(@"_remove_offline_", nil) image:[UIImage imageNamed:image_actionSheetOffline] backgroundColor:[UIColor whiteColor] height: 50.0 type:AHKActionSheetButtonTypeDefault handler:^(AHKActionSheet *as) {
                                    
            if (metadata.directory) {
                                        
                // remove tag offline for all folder/subfolder/file
                NSString *relativeRoot = [CCCoreData getServerUrlFromDirectoryID:metadata.directoryID activeAccount:app.activeAccount];
                NSString *dirServerUrl = [CCUtility stringAppendServerUrl:relativeRoot addFileName:metadata.fileNameData];
                NSArray *directories = [CCCoreData getOfflineDirectoryActiveAccount:app.activeAccount];
                                        
                for (TableDirectory *directory in directories)
                    if ([directory.serverUrl containsString:dirServerUrl]) {
                        [CCCoreData setOfflineDirectoryServerUrl:directory.serverUrl offline:NO activeAccount:app.activeAccount];
                        [CCCoreData removeOfflineAllFileFromServerUrl:directory.serverUrl activeAccount:app.activeAccount];
                    }
                                        
            } else {
                                        
                [CCCoreData setOfflineLocalFileID:metadata.fileID offline:NO activeAccount:app.activeAccount];
            }
                                    
            [self.tableView setEditing:NO animated:YES];
                                    
            [self reloadDatasource];
        }];
    }
    
    // NO Directory - NO Template
    if (metadata.directory == NO && [metadata.type isEqualToString:k_metadataType_template] == NO) {
        
        [actionSheet addButtonWithTitle:NSLocalizedString(@"_open_in_", nil) image:[UIImage imageNamed:image_actionSheetOpenIn] backgroundColor:[UIColor whiteColor] height: 50.0 type:AHKActionSheetButtonTypeDefault handler:^(AHKActionSheet *as) {
            
            [self.tableView setEditing:NO animated:YES];
            [self openWith:metadata];
        }];
    }
    
    [actionSheet addButtonWithTitle:NSLocalizedString(@"_delete_", nil) image:[UIImage imageNamed:image_delete] backgroundColor:[UIColor whiteColor] height: 50.0 type:AHKActionSheetButtonTypeDestructive handler:^(AHKActionSheet *as) {
        
        [self requestDeleteMetadata:metadata indexPath:indexPath];
    }];

    
    [actionSheet show];
}

#pragma --------------------------------------------------------------------------------------------
#pragma mark ==== Table ====
#pragma --------------------------------------------------------------------------------------------

- (CCMetadata *)setSelfMetadataFromIndexPath:(NSIndexPath *)indexPath
{
    NSString *cameraFolderName = [CCCoreData getCameraUploadFolderNameActiveAccount:app.activeAccount];
    NSString *cameraFolderPath = [CCCoreData getCameraUploadFolderPathActiveAccount:app.activeAccount activeUrl:app.activeUrl];
        
    return [CCUtility insertFileSystemInMetadata:[dataSource objectAtIndex:indexPath.row] directory:_serverUrl activeAccount:app.activeAccount cameraFolderName:cameraFolderName cameraFolderPath:cameraFolderPath];
}

- (void)readFolderWithForced:(BOOL)forced serverUrl:(NSString *)serverUrl
{
    [self reloadDatasource];
}

- (void)reloadDatasource
{
    NSArray *subpaths = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:_serverUrl error:nil];
    NSMutableArray *metadatas = [NSMutableArray new];
        
    for (NSString *subpath in subpaths)
        if (![[subpath lastPathComponent] hasPrefix:@"."])
            [metadatas addObject:subpath];
        
    dataSource = [NSArray arrayWithArray:metadatas];
    
    [self.tableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CCLocalStorageCell *cell = (CCLocalStorageCell *)[tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    CCMetadata *metadata;
    
    // separator
    cell.separatorInset = UIEdgeInsetsMake(0.f, 60.f, 0.f, 0.f);
    
    // Initialize
    cell.statusImageView.image = nil;
    cell.offlineImageView.image = nil;
    
    // change color selection
    UIView *selectionColor = [[UIView alloc] init];
    selectionColor.backgroundColor = [[NCBrandColor sharedInstance] getColorSelectBackgrond];
    cell.selectedBackgroundView = selectionColor;

    NSString *cameraFolderName = [CCCoreData getCameraUploadFolderNameActiveAccount:app.activeAccount];
    NSString *cameraFolderPath = [CCCoreData getCameraUploadFolderPathActiveAccount:app.activeAccount activeUrl:app.activeUrl];
        
    metadata = [CCUtility insertFileSystemInMetadata:[dataSource objectAtIndex:indexPath.row] directory:_serverUrl activeAccount:app.activeAccount cameraFolderName:cameraFolderName cameraFolderPath:cameraFolderPath];
        
    cell.fileImageView.image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/.%@.ico", _serverUrl, metadata.fileNamePrint]];
        
    if (!cell.fileImageView.image) {
            
        UIImage *icon = [CCGraphics createNewImageFrom:metadata.fileID directoryUser:_serverUrl fileNameTo:metadata.fileID fileNamePrint:metadata.fileNamePrint size:@"m" imageForUpload:NO typeFile:metadata.typeFile writePreview:NO optimizedFileName:[CCUtility getOptimizedPhoto]];
            
        if (icon) {
            [CCGraphics saveIcoWithFileID:metadata.fileNamePrint image:icon writeToFile:[NSString stringWithFormat:@"%@/.%@.ico", _serverUrl, metadata.fileNamePrint] copy:NO move:NO fromPath:nil toPath:nil];
            cell.fileImageView.image = icon;
        }
    }
    
    // ButtonDown Tapped
    [cell.buttonDown addTarget:self action:@selector(cellButtonDownWasTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    // encrypted color
    if (metadata.cryptated) {
        cell.labelTitle.textColor = [NCBrandColor sharedInstance].cryptocloud;
    } else {
        cell.labelTitle.textColor = [UIColor blackColor];
    }
    
    // File name
    cell.labelTitle.text = metadata.fileNamePrint;
    cell.labelInfoFile.text = @"";
    
    // Immagine del file, se non c'è l'anteprima mettiamo quella standard
    if (cell.fileImageView.image == nil)
        cell.fileImageView.image = [UIImage imageNamed:metadata.iconName];
    
    // it's encrypted ???
    if (metadata.cryptated && [metadata.type isEqualToString: k_metadataType_template] == NO)
        cell.statusImageView.image = [UIImage imageNamed:image_lock];
    
    // text and length
    if (metadata.directory) {
        
        cell.labelInfoFile.text = [CCUtility dateDiff:metadata.date];
        cell.accessoryType = UITableViewCellAccessoryNone;
        //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
          
    } else {
        
        NSString *date = [CCUtility dateDiff:metadata.date];
        NSString *length = [CCUtility transformedSize:metadata.size];
        
        if ([metadata.type isEqualToString: k_metadataType_template])
            cell.labelInfoFile.text = [NSString stringWithFormat:@"%@", date];
        
        if ([metadata.type isEqualToString: k_metadataType_file] || [metadata.type isEqualToString: k_metadataType_local])
            cell.labelInfoFile.text = [NSString stringWithFormat:@"%@ • %@", date, length];
        
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // deselect row
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    _metadata = [self setSelfMetadataFromIndexPath:indexPath];
    
    // if is in download [do not touch]
    if ([_metadata.session length] > 0 && [_metadata.session containsString:@"download"])
        return;
    
    // File
    if (([_metadata.type isEqualToString: k_metadataType_file] || [_metadata.type isEqualToString: k_metadataType_local]) && _metadata.directory == NO) {
        
        if ([_metadata.typeFile isEqualToString: k_metadataTypeFile_unknown] || [_metadata.typeFile isEqualToString: k_metadataTypeFile_compress]) {
            
            [self openWith:_metadata];
            
        } else {
        
            if ([self shouldPerformSegue])
                [self performSegueWithIdentifier:@"segueDetail" sender:self];
        }
    }
    
    // Model
    if ([self.metadata.type isEqualToString: k_metadataType_template])
        [self openModel:_metadata];
    
    // Directory
    if (_metadata.directory)
        [self performSegueDirectoryWithControlPasscode];
}

-(void)performSegueDirectoryWithControlPasscode
{
    CCLocalStorage *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"CCLocalStorage"];
    
    vc.serverUrl = [CCUtility stringAppendServerUrl:_serverUrl addFileName:_metadata.fileNameData];
    vc.titleViewControl = _metadata.fileNamePrint;
    
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma --------------------------------------------------------------------------------------------
#pragma mark ===== Navigation ====
#pragma --------------------------------------------------------------------------------------------

- (BOOL)shouldPerformSegue
{
    // if i am in background -> exit
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateBackground) return NO;
    
    // if i am not window -> exit
    if (self.view.window == NO)
        return NO;
    
    // Collapsed but i am in detail -> exit
    if (self.splitViewController.isCollapsed)
        if (self.detailViewController.isViewLoaded && self.detailViewController.view.window) return NO;
    
    // Video in run -> exit
    if (self.detailViewController.photoBrowser.currentVideoPlayerViewController.isViewLoaded && self.detailViewController.photoBrowser.currentVideoPlayerViewController.view.window) return NO;
    
    return YES;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    id viewController = segue.destinationViewController;
    
    if ([viewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nav = viewController;
        _detailViewController = (CCDetail *)nav.topViewController;
    } else {
        _detailViewController = segue.destinationViewController;
    }
    
    NSMutableArray *allRecordsDataSourceImagesVideos = [NSMutableArray new];
    
    NSString *cameraFolderName = [CCCoreData getCameraUploadFolderNameActiveAccount:app.activeAccount];
    NSString *cameraFolderPath = [CCCoreData getCameraUploadFolderPathActiveAccount:app.activeAccount activeUrl:app.activeUrl];
        
    for (NSString *fileName in dataSource) {
            
        CCMetadata *metadata = [CCMetadata new];
        metadata = [CCUtility insertFileSystemInMetadata:fileName directory:_serverUrl activeAccount:app.activeAccount cameraFolderName:cameraFolderName cameraFolderPath:cameraFolderPath];
            
        if ([metadata.typeFile isEqualToString: k_metadataTypeFile_image] || [metadata.typeFile isEqualToString: k_metadataTypeFile_video])
            [allRecordsDataSourceImagesVideos addObject:metadata];
    }
        
    _detailViewController.sourceDirectoryLocal = YES;
    _detailViewController.metadataDetail = _metadata;
    _detailViewController.dateFilterQuery = nil;
    _detailViewController.isCameraUpload = NO;
    _detailViewController.dataSourceImagesVideos = allRecordsDataSourceImagesVideos;

    [_detailViewController setTitle:_metadata.fileNamePrint];
}

@end
