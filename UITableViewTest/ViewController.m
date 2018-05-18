//
//  ViewController.m
//  UITableViewTest
//
//  Created by Tamas Zahola on 2018. 05. 18..
//  Copyright © 2018. ZT. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <UISearchResultsUpdating,UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, weak) IBOutlet UITableView* tableView;

@end

@implementation ViewController {
    UISearchController* _searchController;
    NSArray<NSString*>* _data;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    _searchController.dimsBackgroundDuringPresentation = NO;
    _searchController.searchResultsUpdater = self;
    self.navigationItem.searchController = _searchController;
    
    NSMutableArray<NSString*>* data = [NSMutableArray new];
    for (int i = 0; i < 100; i++) {
        [data addObject:[NSString stringWithFormat:@"row %d", i]];
    }
    _data = data;
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    [self refresh];
}

- (void)refresh {
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _searchController.searchBar.text.length == 0 ? _data.count : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSAssert(_searchController.searchBar.text.length == 0, @"Invariant violated!");
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.textLabel.text = _data[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_searchController.searchBar.text.length != 0) {
        NSLog(@"Invariant violated!");
    }
}

@end
