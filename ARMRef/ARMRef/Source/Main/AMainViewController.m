//
//  ViewController.m
//  ARMRef
//
//  Created by James Emrich (EvilPenguin) on 6/28/20.
//  Copyright © 2020 James Emrich (EvilPenguin). All rights reserved.
//

#import "AMainViewController.h"
#import "AInstructionLoader.h"
#import "ACollectionView.h"
#import "ACollectionViewDataHandle.h"
#import "AInstructionViewController.h"

@interface AMainViewController () <UISearchBarDelegate, ACollectionViewDelegatesTouchHandle>
@property (nonatomic, weak) AInstructionLoader *loader;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UILabel *noDataLabel;
@property (nonatomic, strong) ACollectionView *collectionView;
@property (nonatomic, strong) ACollectionViewDataHandle *collectionViewDataHandle;
@property (nonatomic, assign) CGRect keyboardFrame;

@end

@implementation AMainViewController

#pragma mark - AMainViewController

- (instancetype) initWithLoader:(AInstructionLoader *)loader {
    if (self = [super init]) {
        self.title  = loader.armVersion;
        self.loader = loader;
        
        [NSNotificationCenter.defaultCenter addObserver:self
                                               selector:@selector(_loaderNotification:)
                                                   name:AInstructionLoaderFinishedNotificaton
                                                 object:nil];
        
        [NSNotificationCenter.defaultCenter addObserver:self
                                               selector:@selector(_keyboardWillChangeFrameNotification:)
                                                   name:UIKeyboardWillChangeFrameNotification
                                                 object:nil];
    }
    
    return self;
}

- (void) viewDidLoad {
    [super viewDidLoad];
    
    // Self
    self.view.backgroundColor = [UIColor colorFromHex:0x333e48];
    
    // Serach
    [self.view addSubview:self.searchBar];
    
    // No data
    [self.view addSubview:self.noDataLabel];
    
    // Collection View
    [self.view addSubview:self.collectionView];
}

- (void) viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    // Points
    CGFloat leftRightInset = self.view.safeAreaInsets.left + self.view.safeAreaInsets.right;
    
    // Search
    self.searchBar.frame = CGRectMake(0.0f, self.view.safeAreaInsets.top, self.view.bounds.size.width, 45.0f);
    
    // No Data
    self.noDataLabel.frame = self.view.bounds;
    
    // Collection view
    CGFloat padding = (!leftRightInset ? 8.0f : 0.0f);
    CGRect collectionViewFrame = CGRectMake(self.view.safeAreaInsets.left + padding,
                                            CGRectGetMaxY(self.searchBar.frame) + 5.0f,
                                            self.view.bounds.size.width - (leftRightInset + (padding * 2.0f)),
                                            self.view.bounds.size.height - (CGRectGetMaxY(self.searchBar.frame) + 5.0f));
    if (self.searchBar.isFirstResponder) collectionViewFrame.size.height -= self.keyboardFrame.size.height;

    self.collectionView.frame = collectionViewFrame;
    [self.collectionView.collectionViewLayout invalidateLayout];
}

#pragma mark - Private

- (void) _loaderNotification:(NSNotification *)notification {
    [self _updateDataAndLoaderWithString:nil];
}

- (void) _updateDataAndLoaderWithString:(NSString *)string {
    self.loader.filerString = string;
    self.collectionViewDataHandle.instructions = self.loader.instructions;
    [self.collectionView reloadData];
    
    [self _showNoDataStyle:!self.collectionViewDataHandle.instructions.count];
}

- (void) _showNoDataStyle:(BOOL)show {
    self.noDataLabel.alpha = (show ? 1.0f : 0.0f);
    self.collectionView.alpha = (show ? 0.0f : 1.0f);
}

- (void) _keyboardWillChangeFrameNotification:(NSNotification *)notification {
    self.keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    [self.view setNeedsLayout];
}

#pragma mark - Lazy

- (UISearchBar *) searchBar {
    if (!_searchBar) {
        _searchBar = [[UISearchBar alloc] init];
        _searchBar.backgroundColor = [UIColor colorFromHex:0x424C54];
        _searchBar.backgroundImage = UIImage.new;
        _searchBar.backgroundImage = UIImage.new;
        _searchBar.tintColor = UIColor.whiteColor;
        _searchBar.delegate = self;
        _searchBar.showsCancelButton = YES;
        _searchBar.searchTextField.backgroundColor = UIColor.whiteColor;
        _searchBar.searchTextField.tintColor = _searchBar.backgroundColor;
        _searchBar.searchTextField.textColor = _searchBar.backgroundColor;
    }
    
    return _searchBar;
}

- (UILabel *) noDataLabel {
    if (!_noDataLabel) {
        _noDataLabel = [[UILabel alloc] init];
        _noDataLabel.font = [UIFont systemFontOfSize:25.0f weight:UIFontWeightMedium];
        _noDataLabel.backgroundColor = UIColor.clearColor;
        _noDataLabel.textColor = UIColor.whiteColor;
        _noDataLabel.textAlignment = NSTextAlignmentCenter;
        _noDataLabel.text = @"No Data...";
    }
    
    return _noDataLabel;
}

- (ACollectionView *) collectionView {
    if (!_collectionView) {
        _collectionView = [[ACollectionView alloc] init];
        _collectionView.dataSource = self.collectionViewDataHandle;
        _collectionView.delegate = self.collectionViewDataHandle;
        _collectionView.alpha = 0.0f;
    }
    
    return _collectionView;
}

- (ACollectionViewDataHandle *) collectionViewDataHandle {
    if (!_collectionViewDataHandle) {
        _collectionViewDataHandle = [[ACollectionViewDataHandle alloc] init];
        _collectionViewDataHandle.handleTouch = self;
    }
    
    return _collectionViewDataHandle;
}

#pragma mark - UISearchBarDelegate

- (void) searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self _updateDataAndLoaderWithString:searchText];
}

- (void) searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self _updateDataAndLoaderWithString:nil];
    
    searchBar.text = nil;
    [searchBar resignFirstResponder];
}

- (void) searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

#pragma mark - ACollectionViewDelegatesTouchHandle

- (void) collectioinViewHandle:(ACollectionViewDataHandle *)handle didTouchInstruction:(AInstruction *)instruction {
    AInstructionViewController *instructionViewController = [[AInstructionViewController alloc] init];
    instructionViewController.instruction = instruction;
    
    [self.navigationController pushViewController:instructionViewController animated:YES];
}

@end

